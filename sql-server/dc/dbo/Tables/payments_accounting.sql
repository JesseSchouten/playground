CREATE TABLE [dbo].[payments_accounting]
(
	[company_account] VARCHAR(20) NOT NULL,
	[merchant_account] VARCHAR(25) NOT NULL,
	[psp_reference] VARCHAR(16),
	[merchant_reference] UNIQUEIDENTIFIER,
	[payment_method] VARCHAR(35),
	[booking_date] DATETIME NOT NULL,
	[time_zone] VARCHAR(6) NOT NULL,
	[main_currency] VARCHAR(5),
	[main_amount] SMALLMONEY,
	[record_type] VARCHAR(35) NOT NULL,
	[payment_currency] VARCHAR(5),
	[received_pc] SMALLMONEY,
	[authorized_pc] SMALLMONEY,
	[captured_pc] SMALLMONEY,
	[settlement_currency] VARCHAR(5),
	[payable_sc] SMALLMONEY,
	[commission_sc] SMALLMONEY,
	[markup_sc] SMALLMONEY,
	[scheme_fees_sc] SMALLMONEY,
	[interchange_sc] SMALLMONEY,
	[processing_fee_currency] VARCHAR(5),
	[processing_fee_fc] SMALLMONEY DEFAULT 0,
	[payment_method_variant] VARCHAR(40),
    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
	INDEX [ncid_1] UNIQUE NONCLUSTERED ([booking_date],[psp_reference], [record_type], [processing_fee_fc]),
)
GO
CREATE NONCLUSTERED INDEX [ncid_2] ON [dbo].[payments_accounting] ([record_type]) INCLUDE ([booking_date], [merchant_reference], [processing_fee_fc]) WITH (ONLINE = ON)


GO
CREATE TRIGGER [dbo].[trgAfterUpdatePaymentsAccounting]
    ON [dbo].[payments_accounting]
    FOR UPDATE
    AS
    UPDATE [dbo].[payments_accounting]
        SET [updated] = GETUTCDATE()
        FROM [payments_accounting] t
        INNER JOIN inserted i 
			ON (
			t.psp_reference = i.psp_reference 
			AND t.booking_date = i.booking_date
			AND t.record_type = i.record_type
			AND t.processing_fee_fc = i.processing_fee_fc
			)