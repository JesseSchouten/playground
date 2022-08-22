CREATE TABLE [settlements_details] (
  -- This is the next iteration of the payments_info table.
  [company_account] VARCHAR(20) NOT NULL,
  [merchant_account] VARCHAR(25) NOT NULL,
  [psp_reference] VARCHAR(16),
  [merchant_reference] UNIQUEIDENTIFIER,
  [payment_method] VARCHAR(30),
  [creation_date] DATETIME NOT NULL,
  [time_zone] VARCHAR(4) NOT NULL,
  [booking_date] DATETIME,
  [booking_date_time_zone] VARCHAR(4),
  [type] VARCHAR(35) NOT NULL,
  [modification_reference] VARCHAR(256) NOT NULL,
  [gross_currency] VARCHAR(3),
  [gross_debit] SMALLMONEY,
  [gross_credit] SMALLMONEY,
  [exchange_rate] DECIMAL(28,17),
  [net_currency] VARCHAR(3),
  [net_debit] SMALLMONEY,
  [net_credit] SMALLMONEY,
  [commission] SMALLMONEY,
  [markup] SMALLMONEY,
  [scheme_fees] SMALLMONEY,
  [interchange] SMALLMONEY,
  [payment_method_variant] VARCHAR(50),
  [batch_number] INT NOT NULL,
  [payment_received_date] DATETIME,
  [afterpay] VARCHAR(15),
  [created] DATETIME DEFAULT (GETUTCDATE()),
  [updated] DATETIME DEFAULT (GETUTCDATE()),
  PRIMARY KEY CLUSTERED ([modification_reference] ASC, [type] ASC, [creation_date] ASC, [batch_number])
);

GO
CREATE INDEX [IX_settlements_details_type_psp_reference_creation_date] ON [dbo].[settlements_details] ([psp_reference], [type], [creation_date])

GO
CREATE NONCLUSTERED INDEX [IX_settlements_details_type_psp_reference] ON [dbo].[settlements_details] ([type], [psp_reference]) INCLUDE ([afterpay], [batch_number], [booking_date], [booking_date_time_zone], [commission], [company_account], [created], [creation_date], [exchange_rate], [gross_credit], [gross_currency], [gross_debit], [interchange], [markup], [merchant_account], [merchant_reference], [modification_reference], [net_credit], [net_currency], [net_debit], [payment_method], [payment_method_variant], [payment_received_date], [scheme_fees], [time_zone], [updated]) WITH (ONLINE = ON)

GO
CREATE NONCLUSTERED INDEX [IX_settlements_details_payment_method] ON [dbo].[settlements_details] ([payment_method]) INCLUDE ([commission], [creation_date], [exchange_rate], [gross_credit], [gross_currency], [gross_debit], [interchange], [markup], [merchant_account], [merchant_reference], [scheme_fees]) WITH (ONLINE = ON)

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSettlementsDetails]
    ON [dbo].[settlements_details]
    FOR UPDATE
    AS
    UPDATE [dbo].[settlements_details]
        SET [updated] = GETUTCDATE()
        FROM [settlements_details] t
        INNER JOIN inserted i 
			ON (
			t.[modification_reference] = i.[modification_reference]
			AND t.[type] = i.[type]
			AND t.[creation_date] = i.[creation_date]
            AND t.[batch_number] = i.[batch_number]
			)
