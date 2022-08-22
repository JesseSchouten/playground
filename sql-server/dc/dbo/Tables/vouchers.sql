CREATE TABLE [dbo].[vouchers]
(
  [voucher_code] VARCHAR(50) NOT NULL PRIMARY KEY,
  [voucher_batch] VARCHAR(50) NOT NULL,
  [purpose] VARCHAR(50) NOT NULL,
  [channel] VARCHAR(3) NOT NULL,
  [country] VARCHAR (2) NOT NULL,
  [subscription_plan_id] VARCHAR(50) NOT NULL,
  [customer_id] UNIQUEIDENTIFIER NULL,
  [subscription_id] UNIQUEIDENTIFIER NULL,
  [issue_date] DATETIME NULL,
  [activation_date] DATETIME NULL,
  [created] DATETIME DEFAULT (GETUTCDATE()) NULL,
  [updated] DATETIME DEFAULT (GETUTCDATE()) NULL
);

GO
CREATE INDEX [IX_vouchers_customer] ON [dbo].[vouchers] ([purpose], [customer_id]);

GO
CREATE INDEX [IX_vouchers_purpose_channel] ON [dbo].[vouchers] ([purpose], [channel], [country], [customer_id]);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateVouchers]
ON [dbo].[vouchers] FOR UPDATE AS
  UPDATE [dbo].[vouchers] SET [updated] = GETUTCDATE()
  FROM [dbo].[vouchers] t
  INNER JOIN inserted i 
  ON (t.voucher_code = i.voucher_code);
