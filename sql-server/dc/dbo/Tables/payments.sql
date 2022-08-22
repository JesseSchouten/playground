CREATE TABLE [payments] (
  [psp_reference] VARCHAR(16) PRIMARY KEY NOT NULL,
  [merchant_reference] UNIQUEIDENTIFIER NOT NULL,
  [merchant_account] VARCHAR(25) NOT NULL,
  [channel] VARCHAR(3),
  [country] VARCHAR(2),
  [creation_date] DATETIME NOT NULL,
  [gross_currency] VARCHAR(5),
  [gross_debit] SMALLMONEY,
  [gross_credit] SMALLMONEY,
  [gross_received] SMALLMONEY,
  [net_currency] VARCHAR(5),
  [net_debit] SMALLMONEY,
  [net_credit] SMALLMONEY,
  [net_received] SMALLMONEY,
  [exchange_rate] DECIMAL(28,17),
  [commission] SMALLMONEY,
  [markup] SMALLMONEY,
  [scheme_fees] SMALLMONEY,
  [interchange] SMALLMONEY,
  [total_fees] SMALLMONEY,
  [suspect_fraud] BIT,
  [has_chargeback] BIT,
  [has_reversed_chargeback] BIT,
  [has_refund] BIT,
  [has_reversed_refund] BIT,
  [cb_is_voluntary] BIT,
  [cb_not_voluntary] BIT,
  [created] DATETIME DEFAULT (GETUTCDATE()),
  [updated] DATETIME DEFAULT (GETUTCDATE())
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdatePayments]
    ON [dbo].[payments]
    FOR UPDATE
    AS
    UPDATE [dbo].[payments]
        SET [updated] = GETUTCDATE()
        FROM [payments] t
        INNER JOIN inserted i 
			ON (
			t.psp_reference = i.psp_reference 
			)
GO

CREATE INDEX [IX_payments_creationdate] ON [dbo].[payments] ([creation_date])

