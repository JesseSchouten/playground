CREATE TABLE [payments_info] (
  -- See settlements_details for the v2 of this table.
  [company_account] VARCHAR(20) NOT NULL,
  [merchant_account] VARCHAR(25) NOT NULL,
  [psp_reference] VARCHAR(16),
  [merchant_reference] UNIQUEIDENTIFIER,
  [payment_method] VARCHAR(35),
  [creation_date] DATETIME NOT NULL,
  [time_zone] VARCHAR(6) NOT NULL,
  [booking_date] DATETIME,
  [booking_date_time_zone] VARCHAR(6),
  [type] VARCHAR(35) NOT NULL,
  [modification_reference] VARCHAR(100) NOT NULL,
  [gross_currency] VARCHAR(5),
  [gross_debit] SMALLMONEY,
  [gross_credit] SMALLMONEY,
  [exchange_rate] DECIMAL(28,17),
  [net_currency] VARCHAR(5),
  [net_debit] SMALLMONEY,
  [net_credit] SMALLMONEY,
  [commission] SMALLMONEY,
  [markup] SMALLMONEY,
  [scheme_fees] SMALLMONEY,
  [interchange] SMALLMONEY,
  [payment_method_variant] VARCHAR(40),
  [batch_number] INT NOT NULL,
  [payment_received_date] DATETIME,
  [afterpay] VARCHAR(15) NULL,
  [created] DATETIME DEFAULT (GETUTCDATE()),
  [updated] DATETIME DEFAULT (GETUTCDATE())
);

GO
CREATE INDEX [IX_payments_info_type_psp_reference_creation_date] ON [dbo].[payments_info] ([psp_reference], [type], [creation_date])

GO
CREATE NONCLUSTERED INDEX [IX_payments_info_type_psp_reference] ON [dbo].[payments_info] ([type], [psp_reference]) INCLUDE ([afterpay], [batch_number], [booking_date], [booking_date_time_zone], [commission], [company_account], [created], [creation_date], [exchange_rate], [gross_credit], [gross_currency], [gross_debit], [interchange], [markup], [merchant_account], [merchant_reference], [modification_reference], [net_credit], [net_currency], [net_debit], [payment_method], [payment_method_variant], [payment_received_date], [scheme_fees], [time_zone], [updated]) WITH (ONLINE = ON)

GO
CREATE TRIGGER [dbo].[trgAfterUpdatePaymentsInfo]
    ON [dbo].[payments_info]
    FOR UPDATE
    AS
    UPDATE [dbo].[payments_info]
        SET [updated] = GETUTCDATE()
        FROM [payments_info] t
        INNER JOIN inserted i 
			ON (
			t.[modification_reference] = i.[modification_reference]
			AND t.[type] = i.[type]
			AND t.[creation_date] = i.[creation_date]
            AND t.[batch_number] = i.[batch_number]
			)
