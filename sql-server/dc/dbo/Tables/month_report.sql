CREATE TABLE [month_report]
(
  [month] DATETIME NOT NULL,
  [channel] VARCHAR(8) NOT NULL,
  [country] VARCHAR(8) NOT NULL,
  [nr_trials] INT NULL,
  [nr_reconnects] INT NULL,
  [nr_unattributed_new_subs] INT NULL,
  [nr_paid_customers] INT NULL,
  [nr_paid_customers_subscriptions] INT NULL,
  [nr_active_customers] INT NULL,
  [nr_active_subscriptions] INT NULL,
  [nr_active_subscriptions_next_month] INT NULL,
  [active_subscription_churn_rate] DECIMAL(8,6),
  [nr_paid_subscriptions] INT NULL,
  [nr_paid_subscriptions_next_month] INT NULL,
  [paid_subscription_churn_rate] DECIMAL(8,6),
  [nr_payments] INT NULL,
  [nr_chargebacks] INT NULL,
  [nr_reversed_chargebacks] INT NULL,
  [nr_refunds] INT NULL,
  [nr_reversed_refunds] INT NULL,
  [net_currency] VARCHAR(5) NULL,
  [net_debit] MONEY NULL,
  [net_credit] MONEY NULL,
  [net_received] MONEY NULL,
  [commission] MONEY NULL,
  [markup] MONEY NULL,
  [scheme_fees] MONEY NULL,
  [interchange] MONEY NULL,
  [total_fees] MONEY NULL,
  [sum_of_gross_sales] MONEY NULL,
  [sum_of_refund_amount] MONEY NULL,
  [sum_of_refund_reversed] MONEY NULL,
  [sum_of_fee] MONEY NULL,
  [sum_of_refund_fee] MONEY NULL,
  [sum_of_transaction_costs] MONEY NULL,
  [sum_of_chargeback_fee] MONEY NULL,
  [sum_of_chargeback] MONEY NULL,
  [sum_of_chargeback_reversed] MONEY NULL,
  [sum_of_invoice_deduction] MONEY NULL,
  [sum_of_balance_transfer] MONEY NULL,
  [sum_of_deposit_correction] MONEY NULL,
  [sum_of_net_payout] MONEY NULL,
  [created] DATETIME DEFAULT (GETUTCDATE()),
  [updated] DATETIME DEFAULT (GETUTCDATE()),
  PRIMARY KEY CLUSTERED ([month] ASC, [channel] ASC, [country] ASC)
);
GO
CREATE TRIGGER [dbo].[trgAfterUpdateMonthReport]
		ON [dbo].[month_report]
		FOR UPDATE
		AS
		UPDATE [dbo].[month_report]
			SET [updated] = GETUTCDATE()
			FROM [month_report] t
  INNER JOIN inserted i
  ON (
				t.month = i.month
    AND t.channel = i.channel
    AND t.country = i.country
				)
GO
CREATE TRIGGER [trgAfterInsertMonthReport]
		ON [dbo].[month_report]
		FOR INSERT
		AS
		UPDATE [dbo].[month_report]
		  SET [created] = GETUTCDATE()
		  FROM Inserted i