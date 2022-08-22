CREATE TABLE [daily_report] (
  [date] DATETIME NOT NULL,
  [channel] VARCHAR(3) NOT NULL,
  [country] VARCHAR(2) NOT NULL,
  [nr_trials] INT NULL,
  [nr_reconnects] INT NULL,
  [nr_paid_customers] INT NULL,
  [nr_paid_customers_subscriptions] INT NULL,
  [nr_active_customers] INT NULL,
  [nr_active_subscriptions] INT NULL,
  [nr_payments] INT NULL,
  [nr_chargebacks] INT NULL,
  [nr_reversed_chargebacks] INT NULL,
  [nr_refunds] INT NULL,
  [nr_reversed_refunds] BIT,
  [net_currency] VARCHAR(5),
  [net_debit] MONEY,
  [net_credit] MONEY,
  [net_received] MONEY,
  [commission] MONEY,
  [markup] MONEY,
  [scheme_fees] MONEY,
  [interchange] MONEY,
  [total_fees] MONEY,
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
  PRIMARY KEY CLUSTERED ([date] ASC, [channel] ASC, [country] ASC)
)

GO
CREATE TRIGGER [dbo].[trgAfterUpdateDailyReport]
    ON [dbo].[daily_report]
    FOR UPDATE
    AS
    UPDATE [dbo].[daily_report]
        SET [updated] = GETUTCDATE()
        FROM [daily_report] t
        INNER JOIN inserted i 
			ON (
			t.[date] = i.[date]
			AND t.channel = i.channel
			AND t.country = i.country
			)