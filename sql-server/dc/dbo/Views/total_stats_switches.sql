CREATE VIEW [dbo].[total_stats_switches] AS
    WITH last_subscription
    (
        subscription_id,
        last_trial_subscription_id
    )
    AS 
    (
        SELECT 
            [total_stats].subscription_id,
            last_trial_subscription_id = FIRST_VALUE([total_stats].subscription_id) OVER (PARTITION BY [total_stats].customer_id ORDER BY [subscriptions].subscription_create_date DESC)
        FROM [dbo].[total_stats]
        INNER JOIN [dbo].[subscriptions] ON [subscriptions].subscription_id = [total_stats].subscription_id
        WHERE [total_stats].trial_gained IS NOT NULL
    ),
    first_subscription
    (
        customer_id,
        first_paid_subscription_id
    )
    AS
    (
        SELECT 
            DISTINCT total_stats.customer_id,
            first_paid_subscription_id = FIRST_VALUE(total_stats.subscription_id) OVER (PARTITION BY total_stats.customer_id ORDER BY subscriptions.subscription_create_date ASC)
        FROM [dbo].[total_stats]
        INNER JOIN [dbo].[subscriptions] ON [dbo].[subscriptions].subscription_id = [dbo].[total_stats].subscription_id
        WHERE [dbo].[total_stats].first_payment_date IS NOT NULL
        AND [dbo].[total_stats].first_payment_success = 1
    ),
    total_stats_extended
    (
        subscription_id,
        subscription_plan_id,
        customer_id,
        first_payment_date,
        first_payment_success,
        issuer_country,
        shopper_country,
        is_switch,
        [status],
        lost_reason,
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
        relevant_value_of_last_billing_cycle,
        last_billing_cycle_start_date,
        last_billing_cycle_end_date,
        trial_gained,
        trial_churned,
        trial_lost,
        subscription_gained,
        subscription_churned,
        subscription_lost,
        subscription_plan_billing_period,
        subscription_plan_business_type,
        marketing_channel,
        created,
        updated,
        first_paid_subscription_id,
        last_trial_subscription_id,
        [state]
    )
    AS 
    (
        SELECT 
            total_stats.*,
            first_subscription.first_paid_subscription_id,
            last_subscription.last_trial_subscription_id,
            subscriptions.state
        FROM [dbo].[total_stats]
        LEFT JOIN [first_subscription] ON [first_subscription].customer_id = [total_stats].customer_id
        LEFT JOIN [last_subscription] ON [last_subscription].subscription_id = [total_stats].subscription_id
        INNER JOIN [dbo].[subscriptions] ON [subscriptions].subscription_id = [total_stats].subscription_id
        WHERE [dbo].[total_stats].is_switch = 0
    ),
    total_stats_extended_switch
    (
        subscription_id,
        subscription_plan_id,
        customer_id,
        first_payment_date,
        first_payment_success,
        issuer_country,
        shopper_country,
        is_switch,
        [status],
        lost_reason,
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
        relevant_value_of_last_billing_cycle,
        last_billing_cycle_start_date,
        last_billing_cycle_end_date,
        trial_gained,
        trial_churned,
        trial_lost,
        subscription_gained,
        subscription_churned,
        subscription_lost,
        subscription_plan_billing_period,
        subscription_plan_business_type,
        marketing_channel,
        created,
        updated,
        first_paid_subscription_id,
        last_trial_subscription_id,
        [state],
        last_status,
        last_subscription_lost,
        last_lost_reason
    )
    AS 
    (
        SELECT 
            total_stats.*,
            first_subscription.first_paid_subscription_id,
            last_subscription.last_trial_subscription_id,
            subscriptions.state,
            last_status = FIRST_VALUE(total_stats.status) OVER (PARTITION BY total_stats.customer_id ORDER BY subscriptions.subscription_create_date DESC),
            last_subscription_lost = FIRST_VALUE(total_stats.subscription_lost) OVER (PARTITION BY total_stats.customer_id ORDER BY subscriptions.subscription_create_date DESC),
            last_lost_reason = FIRST_VALUE(total_stats.lost_reason) OVER(PARTITION BY total_stats.customer_id ORDER BY subscriptions.subscription_create_date DESC)
        FROM [dbo].[total_stats]
        LEFT JOIN [first_subscription] ON [first_subscription].customer_id = [total_stats].customer_id
        LEFT JOIN [last_subscription] ON [last_subscription].subscription_id = [total_stats].subscription_id
        INNER JOIN [dbo].[subscriptions] ON [subscriptions].subscription_id = [total_stats].subscription_id
        WHERE [dbo].[total_stats].is_switch = 1
    ),
    total_stats_switches
    (
        customer_id,
        subscription_id,
        first_subscription_id,
        last_subscription_id,
        first_payment_date,
        first_payment_success,
        issuer_country,
        shopper_country,
        last_status,
        last_lost_reason,
        value_until_cutoff,
        days_remaining,
        value_remaining,
        value_total,
        settled_chargebacks,
        settled_refunds,
        settled_payments,
        gross_sales_settlement_currency,
        gross_sales_foreign_currency,
        gross_debit_chargeback_settlement_currency,
        gross_debit_refunded_settlement_currency,
        gross_currency,
        processing_fee,
        transaction_cost,
        commission,
        markup,
        scheme_fees,
        interchange,
        trial_gained,
        trial_lost,
        subscription_gained,
        subscription_lost,
        is_switch,
        is_reconnect,
        subscription_plan_business_type,
        marketing_channel
    )
    AS
    (
        SELECT
            customer_id,
            subscription_id = MIN(last_trial_subscription_id),
            first_paid_subscription_id = MIN(first_paid_subscription_id),
            last_trial_subscription_id = MIN(last_trial_subscription_id),
            first_payment_date = MIN(first_payment_date),
            first_payment_success = MIN(first_payment_success),
            issuer_country = MIN(issuer_country),
            shopper_country = MIN(shopper_country),
            last_status = MIN(last_status),
            last_lost_reason = MIN(last_lost_reason),
            value_until_cutoff = SUM(value_until_cutoff),
            days_remaining = MAX(days_remaining),
            value_remaining = SUM(value_remaining),
            value_total = SUM(value_total),
            settled_chargebacks = SUM(settled_chargebacks),
            settled_refunds = SUM(settled_refunds),
            settled_payments = SUM(settled_payments),
            gross_sales_settlement_currency = SUM(gross_sales_settlement_currency),
            gross_sales_foreign_currency = SUM(gross_sales_foreign_currency),
            gross_debit_chargeback_settlement_currency = SUM(gross_debit_chargeback_settlement_currency),
            gross_debit_refunded_settlement_currency = SUM(gross_debit_refunded_settlement_currency),
            gross_currency = MIN(gross_currency),
            processing_fee = SUM(processing_fee),
            transaction_cost = SUM(transaction_cost),
            commission = SUM(commission),
            markup = SUM(markup),
            scheme_fees = SUM(scheme_fees),
            interchange = SUM(interchange),
            trial_gained = MIN(trial_gained),
            trial_lost = MAX(trial_lost),
            subscription_gained = MIN(subscription_gained),
            subscription_lost = MIN(last_subscription_lost),
            is_switch = 1,
            is_reconnect = 0,
            subscription_plan_business_type = MIN(subscription_plan_business_type),
            marketing_channel = MIN(marketing_channel)
        FROM [total_stats_extended_switch]
        GROUP BY customer_id
        UNION ALL
        SELECT 
            customer_id,
            subscription_id,
            first_paid_subscription_id,
            last_trial_subscription_id,
            first_payment_date,
            first_payment_success,
            issuer_country,
            shopper_country,
            last_status = [status],
            last_lost_reason = lost_reason,
            value_until_cutoff,
            days_remaining,
            value_remaining,
            value_total,
            settled_chargebacks,
            settled_refunds,
            settled_payments,
            gross_sales_settlement_currency,
            gross_sales_foreign_currency,
            gross_debit_chargeback_settlement_currency,
            gross_debit_refunded_settlement_currency,
            gross_currency,
            processing_fee,
            transaction_cost,
            commission,
            markup,
            scheme_fees,
            interchange,
            trial_gained,
            trial_lost,
            subscription_gained,
            subscription_lost,
            is_switch,
            is_reconnect = CASE 
                WHEN first_paid_subscription_id = subscription_id THEN 0 -- first subscription
                WHEN 
                    first_paid_subscription_id IS NOT NULL
                    AND trial_gained IS NOT NULL
                        THEN 1 
                ELSE 0 
            END,
            subscription_plan_business_type,
            marketing_channel
        FROM [total_stats_extended]
    )
SELECT * FROM [total_stats_switches];
GO