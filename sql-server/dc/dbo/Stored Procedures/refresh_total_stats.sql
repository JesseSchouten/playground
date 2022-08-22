CREATE PROCEDURE dbo.refresh_total_stats AS
BEGIN

    TRUNCATE TABLE dbo.total_stats;

    -- prevent warnings for not counting NULL in aggregate, this is behaviour we want
    SET ANSI_WARNINGS OFF; 

    DECLARE @startDate AS DATE = '2017-12-01';
    DECLARE @endDate AS DATE = GETUTCDATE();

    WITH
    received_payments
    (
        merchant_reference,
        psp_reference_count,
        first_payment_date,
        first_payment_success,
        last_payment_refused,
        last_payment_chargeback
    )
    AS (
        SELECT
            rp.merchant_reference,
            psp_reference_count = COUNT(rp.psp_reference),
            first_payment_date = MIN(rp.booking_date),
            first_payment_success =
            IIF(
                SUM(rp.first_payment_failure) > 0
                AND SUM(rp.first_payment_afterpay_rescue) = 0
                AND SUM(rp.first_payment_autorescue) = 0, 0, 1),
            last_payment_refused = IIF(SUM(rp.last_payment_refused) > 0, 1, 0),
            last_payment_chargeback = IIF(SUM(rp.last_payment_chargeback) > 0, 1, 0)
        FROM
            (
                -- this query finds all received subscription payments
                SELECT
                    payments_accounting.merchant_reference,
                    payments_accounting.psp_reference,
                    payments_accounting.booking_date,
                    payments_accounting.record_type,
                    first_payment_failure =
                    (CASE WHEN (CASE
                        WHEN
                            payments_accounting.psp_reference
                            = (
                                FIRST_VALUE(
                                    payments_accounting.psp_reference
                                ) OVER (
                                    PARTITION BY payments_accounting.merchant_reference ORDER BY
                                        payments_accounting.booking_date ASC
                                )
                            ) THEN payments_accounting.record_type
                        END
                        ) IN (
                            'Refused',
                            'Error',
                            'CaptureFailed',
                            'Chargeback',
                            'Refunded'
                        ) THEN 1
                        ELSE 0
                        END),
                    first_payment_afterpay_rescue =
                    (CASE WHEN (CASE
                        WHEN (settlements_details.afterpay IS NOT NULL
                            AND DATEDIFF(
                                DAY,
                                payments_accounting.booking_date,
                                FIRST_VALUE(
                                    payments_accounting.booking_date
                                ) OVER (
                                    PARTITION BY payments_accounting.merchant_reference ORDER BY
                                        payments_accounting.booking_date ASC
                                )) < 30) -- 30 = the max duration of afterpay
                            THEN payments_accounting.record_type
                        END
                        ) IN (
                            'Settled',
                            'SettledExternally'
                        ) THEN 1
                        ELSE 0
                        END),
                    first_payment_autorescue =
                    (CASE WHEN (CASE
                        WHEN
                            (
                                payments_received.payment_requester_type = 'autorescue'
                                AND DATEDIFF(
                                    DAY,
                                    payments_accounting.booking_date,
                                    FIRST_VALUE(
                                        payments_accounting.booking_date
                                    ) OVER (
                                        PARTITION BY payments_accounting.merchant_reference ORDER BY
                                            payments_accounting.booking_date ASC
                                    )) < 45) -- 45 = the max duration of autorescue
                            THEN payments_accounting.record_type
                        END
                        ) IN (
                            'Settled',
                            'SettledExternally'
                        ) THEN 1
                        ELSE 0
                        END),
                    last_payment_refused = 
                    (CASE WHEN (CASE 
                        WHEN 
                            payments_accounting.psp_reference 
                            = (
                                FIRST_VALUE(
                                    payments_accounting.psp_reference
                                ) OVER (
                                    PARTITION BY payments_accounting.merchant_reference ORDER BY
                                        payments_accounting.booking_date DESC
                                )
                            ) THEN payments_accounting.record_type
                        END
                    ) IN (
                        'Refused'
                    ) THEN 1
                    ELSE 0
                    END),
                    last_payment_chargeback = 
                    (
                        CASE WHEN (CASE 
                            WHEN payments_accounting.psp_reference 
                            = (
                                FIRST_VALUE(
                                    payments_accounting.psp_reference
                                ) OVER (
                                    PARTITION BY payments_accounting.merchant_reference ORDER BY
                                        payments_accounting.booking_date DESC
                                )
                            ) THEN payments_accounting.record_type
                        END
                    ) IN (
                        'Chargeback'
                    ) THEN 1
                    ELSE 0
                    END)
                FROM
                    payments_accounting
                LEFT JOIN
                    payments_received ON
                        payments_received.psp_reference = payments_accounting.psp_reference
                LEFT JOIN
                    settlements_details ON
                        settlements_details.psp_reference = payments_accounting.psp_reference
                LEFT JOIN
                    subscriptions ON
                        subscriptions.subscription_id = payments_accounting.merchant_reference
                WHERE
                    subscriptions.channel IN ('lov', 'nfn')
                    -- ContAuth = recurring payments, or afterpay payments (which are ecommerce)
                    AND (
                        payments_received.shopper_interaction = 'ContAuth'
                        OR (
                            payments_received.shopper_interaction = 'Ecommerce' AND settlements_details.afterpay IS NOT NULL
                        )
                    )
            ) AS rp
        GROUP BY rp.merchant_reference
    ),

    trial_payments_and_switches
    (
        psp_reference,
        booking_date,
        issuer_country,
        shopper_country,
        notes
    )

    AS (
        -- this query finds all received trial payments OR subscriptions which have switched from another subscription
        SELECT
            payments_accounting.psp_reference,
            payments_accounting.booking_date,
            payments_received.issuer_country,
            payments_received.shopper_country,
            subscriptions.notes
        FROM
            payments_accounting
        LEFT JOIN
            payments_received ON
                payments_received.psp_reference = payments_accounting.psp_reference
        LEFT JOIN
            settlements_details ON
                settlements_details.psp_reference = payments_received.psp_reference
        LEFT JOIN
            subscriptions ON
                subscriptions.subscription_id = payments_accounting.merchant_reference
        WHERE
            (
                payments_received.shopper_interaction = 'Ecommerce'
                AND subscriptions.channel IN ('lov', 'nfn')
                AND settlements_details.afterpay IS NULL
                AND payments_accounting.record_type IN ('Received')
            )
            -- Exception list, fc7 = missing in Adyen report, 3da = old messy subscription
            OR subscriptions.subscription_id IN (
                'fc7c8007-cef9-4b1b-957c-a8d219937ea8',
                '3da1e41c-660c-4cbb-bd43-71bba51857db'
            )
            OR (
                subscriptions.switch_from IS NOT NULL OR subscriptions.switch_to IS NOT NULL
            )
    ),

    trial_authorization
    (
        psp_reference,
        issuer_country,
        shopper_country,
        merchant_reference,
        authorization_date
    )

    AS (
        -- plot received trial payments based on successful/unsuccessful trial payments
        -- all potential statuses from Adyen: 'Received', 'Authorised', 'Settled', 'SettledExternally', 'SentForSettle',
        -- 'Refused', 'RefundedExternally', 'Cancelled', 'Error', 'Retried', 'SentForRefund', 'CaptureFailed',
        -- 'Chargeback', 'Refunded'
        SELECT
            payments_accounting.psp_reference,
            issuer_country = MIN(trial_payments_and_switches.issuer_country),
            shopper_country = MIN(trial_payments_and_switches.shopper_country),
            merchant_reference = MIN(payments_accounting.merchant_reference),
            authorization_date = MIN(trial_payments_and_switches.booking_date)
        FROM
            trial_payments_and_switches
        INNER JOIN
            payments_accounting ON
                trial_payments_and_switches.psp_reference = payments_accounting.psp_reference
        GROUP BY payments_accounting.psp_reference
        -- Filter out all failed payments, @todo: ChargebackReversed and RefundReversed happen after this 'negative' status
        -- and should result in inclusion
        HAVING
            SUM(
                CASE
                    WHEN
                        payments_accounting.record_type IN (
                            'Refused',
                            'Refunded',
                            'RefundedExternally',
                            'Error',
                            'CaptureFailed',
                            'Chargeback'
                        )
                        THEN 1 ELSE 0 END) = 0
    ),

    last_marketing_channel_per_sub 
    (
        subscription_id, 
        marketing_channel
    )
    
    AS (
        SELECT 
            x.subscription_id, 
            x.marketing_channel
        FROM (
            SELECT 
                y.subscription_id, 
                y.marketing_channel,
                ROW_NUMBER() OVER (partition by y.subscription_id ORDER BY y.date DESC) AS rank
            FROM dbo.trial_utm_report y
            WHERE marketing_channel != 'unknown') x
        WHERE x.rank = 1
    ),

    subscription_status
    (
        subscription_id,
        subscription_plan_id,
        customer_id,
        first_payment_date,
        first_payment_success,
        last_payment_refused,
        last_payment_chargeback,
        issuer_country,
        shopper_country,
        subscription_create_date,
        subscription_start,
        subscription_end,
        authorization_date,
        cancel_date_notes,
        switch_date_notes,
        switch_to_notes,
        switch_from_notes,
        [status]
    )

    AS (
        SELECT
            -- generic subscription fields
            subscriptions.subscription_id,
            subscription_plan_id = MIN(subscriptions.subscription_plan_id),
            customer_id = MIN(subscriptions.customer_id),
            first_payment_date = CAST(
                MIN(received_payments.first_payment_date) AS DATE
            ),
            first_payment_success = COALESCE(
                MIN(received_payments.first_payment_success), 0
            ),
            last_payment_refused = MIN(received_payments.last_payment_refused),
            last_payment_chargeback = MIN(received_payments.last_payment_chargeback),
            issuer_country = MIN(trial_authorization.issuer_country),
            shopper_country = MIN(trial_authorization.shopper_country),
            subscription_create_date = CAST(
                MIN(
                    CAST(
                        (
                            (
                                subscriptions.subscription_create_date AT TIME ZONE 'UTC'
                            )
                            AT TIME ZONE 'Central Europe Standard Time'
                        ) AS DATETIME)) AS DATE),
            subscription_start = CAST(
                MIN(CAST(((subscriptions.subscription_start AT TIME ZONE 'UTC')
                    AT TIME ZONE 'Central Europe Standard Time'
                    ) AS DATETIME)) AS DATE),
            subscription_end = MIN(subscriptions.subscription_end),
            authorization_date = CAST(
                MIN(trial_authorization.authorization_date) AS DATE
            ),

            -- parsing of notes field for more dates
            cancel_date_notes = MIN(subscriptions.cancel_date),
            switch_date_notes = MIN(subscriptions.switch_date),
            switch_to_notes = MIN(subscriptions.switch_to),
            switch_from_notes = MIN(subscriptions.switch_from),

            -- determine status bucket
            [status] = (CASE
                WHEN (MIN(subscriptions.state) IS NULL) THEN 'bug_empty_state'

                -- Paused and forced paused
                WHEN
                    (
                        MIN(
                            subscriptions.state
                        ) = 'paused' AND MIN(
                            trial_authorization.authorization_date
                        ) IS NOT NULL AND MIN(
                            received_payments.first_payment_date
                        ) IS NULL
                    ) THEN 'bug_trial_paused'

                WHEN (MIN(subscriptions.state) = 'paused') THEN 'paused'
                WHEN (MIN(subscriptions.state) = 'onhold') THEN 'onhold'

                -- Pending states
                WHEN
                    (
                        MIN(
                            subscriptions.subscription_end
                        ) >= CAST(
                            GETUTCDATE() AS DATE
                        ) AND MIN(subscriptions.state) = 'pending'
                    ) THEN 'bug_switch_active'
                WHEN
                    (
                        MIN(
                            subscriptions.recurring_enabled + 0
                        ) = 1 AND MIN(
                            subscriptions.subscription_end
                        ) < CAST(
                            GETUTCDATE() AS DATE
                        ) AND MIN(subscriptions.state) = 'pending'
                    ) THEN 'bug_switch_inactive'
                WHEN
                    (
                        MIN(
                            trial_authorization.authorization_date
                        ) IS NOT NULL AND MIN(subscriptions.state) = 'pending'
                    ) THEN 'bug_trial_not_activated'
                WHEN (MIN(subscriptions.state) = 'pending') THEN 'pending'

                -- Trial states

                -- if there is a successful trial payment and no subscription payments, subscription is trial
                WHEN
                    (
                        MIN(trial_authorization.authorization_date) IS NOT NULL
                        AND MIN(received_payments.first_payment_date) IS NULL
                        AND MIN(
                            subscriptions.subscription_end
                        ) >= CAST(GETUTCDATE() AS DATE)
                    ) THEN 'trial'
                WHEN
                    (
                        MIN(trial_authorization.authorization_date) IS NOT NULL
                        AND (
                            MIN(
                                received_payments.first_payment_date
                            ) IS NULL OR MIN(
                                received_payments.first_payment_success
                            ) = 0
                        )
                        AND MIN(
                            subscriptions.subscription_end
                        ) < CAST(GETUTCDATE() AS DATE)
                        AND MIN(subscriptions.recurring_enabled + 0) = 0
                    ) THEN 'trial_churned'
                WHEN
                    (
                        MIN(trial_authorization.authorization_date) IS NOT NULL
                        AND (
                            MIN(
                                received_payments.first_payment_date
                            ) IS NULL OR MIN(
                                received_payments.first_payment_success
                            ) = 0
                        )
                        AND MIN(
                            subscriptions.subscription_end
                        ) < CAST(GETUTCDATE() AS DATE)
                        AND MIN(subscriptions.recurring_enabled + 0) = 1
                    ) THEN 'bug_churned_trial'

                -- Unpaid states
                -- Optional: AND MIN(s.notes) LIKE '%Created and switched from%'
                WHEN
                    (
                        MIN(trial_authorization.authorization_date) IS NULL
                        AND MIN(received_payments.first_payment_date) IS NULL
                        AND MIN(
                            subscriptions.subscription_end
                        ) >= CAST(GETUTCDATE() AS DATE)
                        AND MIN(subscriptions.recurring_enabled + 0) = 1
                    ) THEN 'bug_switch_paid'
                WHEN
                    (
                        MIN(
                            subscriptions.recurring_enabled + 0
                        ) = 1 AND MIN(
                            subscriptions.subscription_end
                        ) < CAST(GETUTCDATE() AS DATE)
                    ) THEN 'bug_unbilled'

                -- Paid states
                WHEN
                    (
                        MIN(received_payments.first_payment_date) IS NOT NULL
                        AND MIN(
                            subscriptions.subscription_end
                        ) >= CAST(GETUTCDATE() AS DATE)
                    ) THEN 'paid'
                WHEN
                    (
                        MIN(received_payments.first_payment_date) IS NOT NULL
                        AND MIN(
                            subscriptions.subscription_end
                        ) < CAST(GETUTCDATE() AS DATE)
                    ) THEN 'paid_churned'

                WHEN
                    (
                        MIN(
                            subscriptions.subscription_start
                        ) > DATEADD(DAY, 2, GETUTCDATE())
                    ) THEN 'bug_invalid_subscription_start'

                WHEN
                    (
                        MIN(
                            subscriptions.recurring_enabled + 0
                        ) = 0 AND MIN(
                            subscriptions.subscription_end
                        ) < CAST(
                            GETUTCDATE() AS DATE
                        ) AND COUNT(
                            trial_authorization.psp_reference
                        ) = 0
                        AND MIN(received_payments.first_payment_date) IS NULL
                    ) THEN 'bug_switch_churned'

                ELSE 'unknown'
                -- Afterpay
                -- Autorescue
                -- Vouchers
                END)
        FROM
            trial_authorization
        LEFT JOIN
            received_payments ON
                received_payments.merchant_reference = trial_authorization.merchant_reference
        FULL OUTER JOIN
            subscriptions ON
                subscriptions.subscription_id = trial_authorization.merchant_reference
        WHERE subscriptions.channel IN ('lov', 'nfn')
            AND CAST(
                (
                    (
                        subscriptions.subscription_create_date AT TIME ZONE 'UTC'
                    ) AT TIME ZONE 'Central Europe Standard Time'
                ) AS DATE
            ) < CAST(GETUTCDATE() AS DATE)
        GROUP BY subscriptions.subscription_id
    ),

    payments
    (
        merchant_reference,
        exchange_rate,
        gross_currency,
        last_billing_gross_credit,
        last_billing_gross_debit,
        last_billing_gross_exchange_rate,
        last_billing_creation_date,
        settled_chargebacks,
        settled_refunds,
        settled_payments,
        gross_sales,
        gross_credit,
        gross_debit,
        gross_credit_settlement_currency,
        gross_debit_chargeback_settlement_currency,
        gross_debit_refunded_settlement_currency,
        transaction_costs,
        commission,
        markup,
        scheme_fees,
        interchange
    )

    AS (
        SELECT
            merchant_reference,
            -- Filter the last billing relative to cutoff date to 'split' the last billing in case of value change
            -- Say that the last billing amount from 5.95 to 6.95, we want to be able to allocate only the 
            -- relevant amount of days worth of '6.95' to the average value, only if the 'rest value' is in the future
            exchange_rate,
            gross_currency,
            last_billing_gross_credit = COALESCE(
                FIRST_VALUE(
                    gross_credit
                ) OVER (
                    PARTITION BY merchant_reference ORDER BY creation_date DESC
                ),
                0
            ),
            last_billing_gross_debit = COALESCE(
                FIRST_VALUE(
                    gross_debit
                ) OVER (
                    PARTITION BY merchant_reference ORDER BY creation_date DESC
                ),
                0
            ),
            -- Calculate gross sales in settlement currency
            last_billing_gross_exchange_rate = FIRST_VALUE(
                exchange_rate
            ) OVER (
                PARTITION BY merchant_reference ORDER BY creation_date DESC
            ),
            last_billing_creation_date = FIRST_VALUE(
                creation_date
            ) OVER (
                PARTITION BY merchant_reference ORDER BY creation_date DESC
            ),
            -- 1 is some manually chosen arbitrary cutoff to exclude trial chargebacks. Might change in future.
            settled_chargebacks = IIF(
                type = 'Chargeback' AND gross_debit > 1, COALESCE(1, 0), 0
            ),
            -- 1 is some manually chosen arbitrary cutoff to exclude trial refunds. Might change in future.
            settled_refunds = IIF(
                type = 'Refunded' AND gross_debit > 1, COALESCE(1, 0), 0
            ),
            -- 1 is some manually chosen arbitrary cutoff to exclude trial payments. Might change in future.
            settled_payments = IIF(
                type = 'Settled' AND gross_credit > 1, COALESCE(1, 0), 0
            ),
            gross_sales = (
                (
                    COALESCE(gross_credit, 0) - COALESCE(gross_debit, 0)
                ) * exchange_rate
            ),
            gross_credit = COALESCE(gross_credit, 0),
            gross_debit = COALESCE(gross_debit, 0),
            gross_credit_settlement_currency = COALESCE(
                gross_credit * exchange_rate, 0
            ),
            gross_debit_chargeback_settlement_currency = IIF(
                type = 'Chargeback', COALESCE(gross_debit, 0) * exchange_rate, 0
            ),
            gross_debit_refunded_settlement_currency = IIF(
                type = 'Refunded', COALESCE(gross_debit, 0) * exchange_rate, 0
            ),
            -- These are all the transaction cost columns
            transaction_costs = (
                COALESCE(
                    commission, 0
                ) + COALESCE(
                    markup, 0
                ) + COALESCE(scheme_fees, 0) + COALESCE(interchange, 0)
            ),
            commission = COALESCE(commission, 0),
            markup = COALESCE(markup, 0),
            scheme_fees = COALESCE(scheme_fees, 0),
            interchange = COALESCE(interchange, 0)
        FROM settlements_details
        -- Filter on cutoff date
        WHERE creation_date BETWEEN @startDate AND @endDate
            -- Exclude all Paypal payments due to to lack of exchange rate
            AND payment_method NOT IN ('paypal')
        UNION ALL
        SELECT
            merchant_reference,
            -- Filter the last billing relative to cutoff date to 'split' the last billing in case of value change
            -- Say that the last billing amount from 5.95 to 6.95, we want to be able to allocate only the 
            -- relevant amount of days worth of '6.95' to the average value, only if the 'rest value' is in the future
            exchange_rate,
            gross_currency,
            last_billing_gross_credit = 0,
            last_billing_gross_debit = 0,
            -- Calculate gross sales in settlement currency
            last_billing_gross_exchange_rate = 0,
            last_billing_creation_date = 0,
            settled_chargebacks = 0,
            settled_refunds = IIF(
                type = 'SentForRefund' AND gross_debit > 1, COALESCE(1, 0), 0
            ),
            settled_payments = IIF(
                type = 'SentForSettle' AND gross_credit > 1, COALESCE(1, 0), 0
            ),
            gross_sales = 0,
            gross_credit = 0,
            gross_debit = 0,
            gross_credit_settlement_currency = 0,
            gross_debit_chargeback_settlement_currency = 0,
            gross_debit_refunded_settlement_currency = 0,
            -- These are all the transaction cost columns
            transaction_costs = 0,
            commission = 0,
            markup = 0,
            scheme_fees = 0,
            interchange = 0
        FROM settlements_details
        -- Filter on cutoff date
        WHERE creation_date BETWEEN @startDate AND @endDate
            -- Exclude all Paypal payments due to to lack of exchange rate
            AND payment_method IN ('paypal')
    ),
    
    payment_summary
    (
        merchant_reference,
        last_billing_gross_credit,
        last_billing_gross_debit,
        last_billing_gross_exchange_rate,
        last_billing_creation_date,
        last_billing_gross_sales,
        settled_chargebacks,
        settled_refunds,
        settled_payments,
        gross_sales,
        gross_credit,
        gross_debit,
        gross_credit_settlement_currency,
        gross_debit_chargeback_settlement_currency,
        gross_debit_refunded_settlement_currency,
        gross_currency,
        transaction_costs,
        commission,
        markup,
        scheme_fees,
        interchange
    )

    AS (
        SELECT
            payments.merchant_reference,
            -- We can take the MAX aggregate from these values as they are all the same. 
            -- AVG, MIN would all give the same result
            last_billing_gross_credit = MAX(last_billing_gross_credit),
            last_billing_gross_debit = MAX(last_billing_gross_debit),
            last_billing_gross_exchange_rate = MAX(
                last_billing_gross_exchange_rate
            ),
            last_billing_creation_date = MAX(last_billing_creation_date),
            last_billing_gross_sales = (
                MAX(last_billing_gross_credit) - MAX(last_billing_gross_debit)
            ) * MAX(last_billing_gross_exchange_rate),
            settled_chargebacks = SUM(settled_chargebacks),
            settled_refunds = SUM(settled_refunds),
            settled_payments = SUM(settled_payments),
            -- sales columns
            gross_sales = SUM(gross_sales),
            gross_credit = SUM(gross_credit),
            gross_debit = SUM(gross_debit),
            gross_credit_settlement_currency = SUM(
                gross_credit_settlement_currency
            ),
            gross_debit_chargeback_settlement_currency = SUM(
                gross_debit_chargeback_settlement_currency
            ),
            gross_debit_refunded_settlement_currency = SUM(
                gross_debit_refunded_settlement_currency
            ),
            gross_currency = MIN(gross_currency),
            -- cost columns
            transaction_costs = SUM(transaction_costs),
            commission = SUM(commission),
            markup = SUM(markup),
            scheme_fees = SUM(scheme_fees),
            interchange = SUM(interchange)
        FROM payments
        GROUP BY payments.merchant_reference
    ),

    payment_fees
    (
        merchant_reference,
        processing_fee
    )

    AS (
        SELECT
            merchant_reference,
            -- fc = foreign currency, however fees are always calculated in the merchant currency, = EUR
            processing_fee = SUM(processing_fee_fc)
        FROM payments_accounting
        WHERE
            -- fees are only relevant for these two statuses
            -- (see https://docs.adyen.com/reporting/invoice-reconciliation)
            record_type IN ('Received', 'SentForRefund')
            -- Filter these on cutoff date as to not calculate fees for the future
            AND booking_date BETWEEN @startDate AND @endDate
        GROUP BY merchant_reference
    ),

    first_payment
    (
        merchant_reference,
        first_payment_date
    )

    AS (
        SELECT
            settlements_details.merchant_reference,
            first_payment_date = MIN(settlements_details.creation_date)
        FROM settlements_details
        INNER JOIN
            payments_received ON
                payments_received.psp_reference = settlements_details.psp_reference
        WHERE payments_received.shopper_interaction = 'ContAuth'
            AND settlements_details.afterpay IS NULL
        GROUP BY settlements_details.merchant_reference
    ),

    summary
    (
        merchant_reference,
        last_billing_gross_credit,
        last_billing_gross_debit,
        last_billing_gross_exchange_rate,
        last_billing_creation_date,
        last_billing_gross_sales,
        settled_chargebacks,
        settled_refunds,
        settled_payments,
        gross_sales,
        gross_credit,
        gross_debit,
        gross_credit_settlement_currency,
        gross_debit_chargeback_settlement_currency,
        gross_debit_refunded_settlement_currency,
        gross_currency,
        transaction_costs,
        commission,
        markup,
        scheme_fees,
        interchange,
        subscription_id,
        recurring_enabled,
        first_payment_date,
        subscription_end_date,
        subscription_plan_billing_frequency,
        subscription_plan_price,
        processing_fee,
        subscription_create_date,
        cutoff_or_subscription_end,
        duration_until_cutoff_or_subscription_end,
        absolute_subscription_duration,
        relative_subscription_duration,
        last_cycle_remaining_days,
        duration_without_last_cycle,
        last_billing_amount
    )

    AS (
        SELECT
            payment_summary.*,
            subscriptions.subscription_id,
            subscriptions.recurring_enabled,
            first_payment_date = first_payment.first_payment_date,
            subscription_end_date = subscriptions.subscription_end,
            subscription_plan_billing_frequency = subscription_plan.billing_frequency,
            subscription_plan_price = subscription_plan.price,
            payment_fees.processing_fee,
            -- Calculate the duration until cutoff date, or subscription_end if it is earlier
            subscription_create_date = FORMAT(
                subscriptions.subscription_create_date, 'yyyy-MM-dd'
            ),
            -- Calculate the absolute subscription duration from start to end
            -- NOTE: Not used but added for clarity
            cutoff_or_subscription_end = LEAST(
                @endDate, subscriptions.subscription_end
            ),
            -- Calculate the amount of days from the absolute subscription start date until the 'relative subscription_end date'
            -- The relative subscription end date being the end date at the cutoff point, measured from the last billing
            -- date filtered in the subquery based on booking date. 
            -- @TODO: allow for billing frequency changes, one solution would be to look at times between billings 
            duration_until_cutoff_or_subscription_end = DATEDIFF(
                DAY,
                subscriptions.subscription_create_date,
                LEAST(@endDate, subscriptions.subscription_end)
            ),
            -- Calculate the amount of 'remaining days' left from the 'last' billing cycle to the relative end date
            -- NOTE: Not used
            absolute_subscription_duration = DATEDIFF(
                DAY,
                subscriptions.subscription_create_date,
                subscriptions.subscription_end
            ),
            -- Calculate the duration of all old cycles, minus the relative last one
            relative_subscription_duration = DATEDIFF(
                DAY,
                subscriptions.subscription_create_date,
                LEAST(
                    DATEADD(
                        DAY,
                        subscription_plan.billing_frequency,
                        payment_summary.last_billing_creation_date
                    ),
                    subscriptions.subscription_end
                )
            ),
            -- Last billing amount is the last billing amount IF the billing cycle 'overflows' past the cutoff date
            -- Else it should be counted towards 'old billing' and therefor set to 0 here
            last_cycle_remaining_days = GREATEST(
                DATEDIFF(
                    DAY,
                    @endDate,
                    DATEADD(
                        DAY,
                        subscription_plan.billing_frequency,
                        payment_summary.last_billing_creation_date
                    )
                ),
                0
            ),
            duration_without_last_cycle = GREATEST(
                DATEDIFF(
                    DAY,
                    subscriptions.subscription_create_date,
                    LEAST(
                        DATEADD(
                            DAY,
                            subscription_plan.billing_frequency,
                            payment_summary.last_billing_creation_date
                        ),
                        subscriptions.subscription_end
                    ) - subscription_plan.billing_frequency
                ),
                0
            ),
            last_billing_amount =
            GREATEST(
                IIF(
                    DATEADD(
                        DAY,
                        subscription_plan.billing_frequency,
                        payment_summary.last_billing_creation_date
                    ) < @endDate,
                    0,
                    payment_summary.last_billing_gross_sales
                ), 0)
        FROM subscriptions
        LEFT JOIN
            subscription_plan ON
                subscription_plan.id = subscriptions.subscription_plan_id
        LEFT JOIN
            payment_fees ON
                payment_fees.merchant_reference = subscriptions.subscription_id
        LEFT JOIN
            payment_summary ON
                payment_summary.merchant_reference = subscriptions.subscription_id
        -- Get first payment date, or 'date that subscription became paid'
        LEFT JOIN
            first_payment ON
                first_payment.merchant_reference = subscriptions.subscription_id
        -- Also filter subscriptions on only subscription created before the cutoff date
        -- Adjust created date 
        WHERE
            CAST(
                (
                    (
                        subscriptions.subscription_create_date AT TIME ZONE 'UTC'
                    ) AT TIME ZONE 'Central Europe Standard Time'
                ) AS DATE
            ) < @endDate
    ),

    total_summary
    (
        merchant_reference,
        last_billing_gross_credit,
        last_billing_gross_debit,
        last_billing_gross_exchange_rate,
        last_billing_creation_date,
        last_billing_gross_sales,
        settled_chargebacks,
        settled_refunds,
        settled_payments,
        gross_sales,
        gross_credit,
        gross_debit,
        gross_credit_settlement_currency,
        gross_debit_chargeback_settlement_currency,
        gross_debit_refunded_settlement_currency,
        gross_currency,
        transaction_costs,
        commission,
        markup,
        scheme_fees,
        interchange,
        subscription_id,
        recurring_enabled,
        first_payment_date,
        subscription_end_date,
        subscription_plan_billing_frequency,
        subscription_plan_price,
        processing_fee,
        subscription_create_date,
        cutoff_or_subscription_end,
        duration_until_cutoff_or_subscription_end,
        absolute_subscription_duration,
        relative_subscription_duration,
        last_cycle_remaining_days,
        duration_without_last_cycle,
        last_billing_amount,
        value_without_last_cycle,
        value_without_last_cycle_per_day,
        value_in_current_pd,
        relevant_days_of_last_billing_cycle,
        relevant_value_of_last_billing_cycle,
        total_value_until_last,
        remaining_days,
        remaining_value
    )

    AS (
        SELECT
            summary.*,
            value_without_last_cycle = summary.gross_sales - summary.last_billing_amount,
            -- Calculate the value of all cycles up until the relative last one per day
            value_without_last_cycle_per_day =
            IIF(
                summary.duration_without_last_cycle > 0, -- prevent div / 0
                (
                    summary.gross_sales - summary.last_billing_amount
                ) / summary.duration_without_last_cycle,
                0
            ),
            -- Calculate the value per day of the last cycle
            value_in_current_pd = summary.last_billing_amount / summary.subscription_plan_billing_frequency,
            -- Calculate the amount of days of the last billing cycle still relevant for the current one
            relevant_days_of_last_billing_cycle = summary.duration_until_cutoff_or_subscription_end - (
                summary.relative_subscription_duration - summary.subscription_plan_billing_frequency
            ),
            relevant_value_of_last_billing_cycle = (
                summary.duration_until_cutoff_or_subscription_end - (
                    summary.relative_subscription_duration - summary.subscription_plan_billing_frequency
                )
            ) * (
                summary.last_billing_amount / summary.subscription_plan_billing_frequency
            ),
            total_value_until_last = (
                summary.gross_sales - summary.last_billing_amount
            ) + (
                (
                    summary.duration_until_cutoff_or_subscription_end - (
                        summary.relative_subscription_duration - summary.subscription_plan_billing_frequency
                    )
                ) * (
                    summary.last_billing_amount / summary.subscription_plan_billing_frequency
                )
            ),
            remaining_days = GREATEST(
                summary.subscription_plan_billing_frequency - (
                    summary.duration_until_cutoff_or_subscription_end - (
                        summary.relative_subscription_duration - summary.subscription_plan_billing_frequency
                    )
                ),
                0
            ),
            remaining_value = GREATEST(
                summary.subscription_plan_billing_frequency - (
                    summary.duration_until_cutoff_or_subscription_end - (
                        summary.relative_subscription_duration - summary.subscription_plan_billing_frequency
                    )
                ),
                0
            ) * (
                summary.last_billing_amount / summary.subscription_plan_billing_frequency
            )
        FROM summary
    ),

    revenue_summary
    (
        subscription_id,
        value_until_cutoff,
        days_remaining,
        value_remaining,
        value_total,
        settled_chargebacks,
        settled_refunds,
        settled_payments,
        gross_sales_settlement_currency,
        gross_sales_foreign_currency,
        gross_credit_settlement_currency,
        gross_debit_chargeback_settlement_currency,
        gross_debit_refunded_settlement_currency,
        gross_currency,
        processing_fee,
        transaction_cost,
        commission,
        markup,
        scheme_fees,
        interchange,
        first_payment_date,
        relevant_value_of_last_billing_cycle,
        last_billing_cycle_start_date,
        last_billing_cycle_end_date
    )

    AS (
        SELECT
            total_summary.subscription_id,
            value_until_cutoff = ROUND(
                COALESCE(SUM(total_summary.total_value_until_last), 0), 2
            ),
            days_remaining = MAX(total_summary.remaining_days),
            value_remaining = ROUND(
                COALESCE(SUM(total_summary.remaining_value), 0), 2
            ),
            value_total = ROUND(
                COALESCE(
                    SUM(total_summary.total_value_until_last), 0
                ) + COALESCE(SUM(total_summary.remaining_value), 0),
                2
            ),
            settled_chargebacks = COALESCE(SUM(settled_chargebacks), 0),
            settled_refunds = COALESCE(SUM(settled_refunds),0),
            settled_payments = COALESCE(SUM(settled_payments),0),
            gross_sales_settlement_currency = ROUND(
                COALESCE(SUM(total_summary.gross_sales), 0), 2
            ),
            gross_sales_foreign_currency = ROUND(
                COALESCE(
                    SUM(total_summary.gross_credit), 0
                ) - COALESCE(SUM(total_summary.gross_debit), 0),
                2
            ),
            gross_credit_settlement_currency = ROUND(
                COALESCE(
                    SUM(total_summary.gross_credit_settlement_currency), 0
                ),
                2
            ),
            gross_debit_chargeback_settlement_currency = ROUND(
                COALESCE(
                    SUM(
                        total_summary.gross_debit_chargeback_settlement_currency
                    ),
                    0
                ),
                2
            ),
            gross_debit_refunded_settlement_currency = ROUND(
                COALESCE(
                    SUM(total_summary.gross_debit_refunded_settlement_currency),
                    0
                ),
                2
            ),
            gross_currency = MIN(total_summary.gross_currency),
            processing_fee = ROUND(
                COALESCE(SUM(total_summary.processing_fee), 0), 2
            ),
            transaction_cost = ROUND(
                COALESCE(SUM(total_summary.transaction_costs), 0), 2
            ),
            commission = ROUND(COALESCE(SUM(total_summary.commission), 0), 2),
            markup = ROUND(COALESCE(SUM(total_summary.markup), 0), 2),
            scheme_fees = ROUND(COALESCE(SUM(total_summary.scheme_fees), 0), 2),
            interchange = ROUND(COALESCE(SUM(total_summary.interchange), 0), 2),
            -- check columns for validation
            first_payment_date = MIN(total_summary.first_payment_date),
            relevant_value_of_last_billing_cycle = ROUND(
                MAX(total_summary.relevant_value_of_last_billing_cycle), 2
            ),
            last_billing_cycle_start_date = MAX(
                total_summary.last_billing_creation_date
            ),
            last_billing_cycle_end_date = DATEADD(
                DAY,
                MAX(total_summary.subscription_plan_billing_frequency),
                MAX(total_summary.last_billing_creation_date)
            )
        FROM total_summary
        GROUP BY total_summary.subscription_id
    )

    INSERT INTO [dbo].total_stats SELECT * FROM
        (
            SELECT
                -- Columns from subscription_status
                subscription_status.subscription_id,
                subscription_status.subscription_plan_id,
                subscription_status.customer_id,
                subscription_status.first_payment_date,
                subscription_status.first_payment_success,
                subscription_status.issuer_country,
                subscription_status.shopper_country,
                is_switch = IIF(
                    subscription_status.switch_to_notes IS NULL AND subscription_status.switch_from_notes IS NULL,
                    0,
                    1
                ),
                subscription_status.status,
                lost_reason = CASE
                    WHEN [status] IN ('paid', 'trial') THEN NULL
                    WHEN subscription_status.cancel_date_notes IS NOT NULL THEN 'cancel'
                    WHEN subscription_status.last_payment_refused = 1 THEN 'payment_refused'
                    WHEN subscription_status.last_payment_chargeback = 1 THEN 'payment_chargeback'
                    ELSE NULL
                END,

                -- Columns from revenue_summary
                revenue_summary.value_until_cutoff,
                revenue_summary.days_remaining,
                revenue_summary.value_remaining,
                revenue_summary.value_total,
                revenue_summary.settled_chargebacks,
                revenue_summary.settled_refunds,
                revenue_summary.settled_payments,
                revenue_summary.gross_sales_settlement_currency,
                revenue_summary.gross_sales_foreign_currency,
                revenue_summary.gross_credit_settlement_currency,
                revenue_summary.gross_debit_chargeback_settlement_currency,
                revenue_summary.gross_debit_refunded_settlement_currency,
                revenue_summary.gross_currency,
                revenue_summary.processing_fee,
                revenue_summary.transaction_cost,
                revenue_summary.commission,
                revenue_summary.markup,
                revenue_summary.scheme_fees,
                revenue_summary.interchange,
                revenue_summary.relevant_value_of_last_billing_cycle,
                revenue_summary.last_billing_cycle_start_date,
                revenue_summary.last_billing_cycle_end_date,
                trial_gained = subscription_status.authorization_date,

                trial_churned = IIF(
                    subscription_status.status IN (
                        'trial', 'trial_churned', 'bug_trial_not_activated'
                    ),
                    subscription_status.cancel_date_notes,
                    NULL),
                trial_lost = IIF(
                    (subscription_status.status IN (
                        'trial', 'trial_churned', 'bug_trial_not_activated'
                    ) OR (
                        subscription_status.status = 'onhold' AND subscription_status.first_payment_success = 0
                    )
                    ) AND CAST(
                        subscription_status.subscription_end AS DATE
                    ) < CAST(GETUTCDATE() AS DATE),
                    subscription_status.subscription_end,
                    NULL
                ),

                subscription_gained = IIF(
                    subscription_status.first_payment_success = 1,
                    CAST(subscription_status.first_payment_date AS DATE),
                    NULL
                ),
                subscription_churned = IIF(
                    subscription_status.status IN ('paid', 'paid_churned'),
                    subscription_status.cancel_date_notes,
                    NULL),

                subscription_lost = IIF(
                    (
                        subscription_status.first_payment_date IS NOT NULL AND subscription_status.first_payment_success = 1
                    ) AND subscription_status.status NOT IN (
                        'paused'
                    ) AND CAST(
                        subscription_status.subscription_end AS DATE
                    ) < CAST(GETUTCDATE() AS DATE),
                    subscription_status.subscription_end,
                    NULL
                ),
                subscription_plan_billing_period = (
                    CASE subscription_plan.billing_frequency
                        WHEN
                            365 THEN 'yearly'
                        WHEN 30 THEN 'monthly' ELSE 'monthly'
                    END
                ),

                subscription_plan_business_type = IIF(
                    ISJSON(subscription_plan.description) > 0,
                    JSON_VALUE(
                        subscription_plan.description, '$.business_type'
                    ),
                    NULL
                ),
                CASE WHEN last_marketing_channel_per_sub.marketing_channel IS NULL THEN 'unknown' ELSE last_marketing_channel_per_sub.marketing_channel END AS marketing_channel,
                CURRENT_TIMESTAMP as created,
                CURRENT_TIMESTAMP as updated
            FROM
                subscription_status
            LEFT JOIN
                customers ON
                    customers.customer_id = subscription_status.customer_id
            LEFT JOIN
                subscription_plan ON
                    subscription_plan.id = subscription_status.subscription_plan_id
            LEFT JOIN
                revenue_summary ON
                    revenue_summary.subscription_id = subscription_status.subscription_id
            LEFT JOIN
                last_marketing_channel_per_sub ON
                    last_marketing_channel_per_sub.subscription_id = subscription_status.subscription_id
        ) AS total_stats;
END
