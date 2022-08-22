-- base fields: https://docs.adyen.com/issuing/report-types/received-payments-report
-- extended fields: https://docs.adyen.com/reporting/invoice-reconciliation/payment-accounting-report
CREATE TABLE [dbo].[payments_received]
(
	[company_account] VARCHAR(20) NOT NULL,
	[merchant_account] VARCHAR(25) NOT NULL,
	[psp_reference] VARCHAR(16) PRIMARY KEY,
	[merchant_reference] UNIQUEIDENTIFIER,
	[payment_method] VARCHAR(35),
	[creation_date] DATETIME NOT NULL,
    [time_zone] VARCHAR(6) NOT NULL,
    [currency] VARCHAR(3),
	[amount] SMALLMONEY,
	[type] VARCHAR(16) NOT NULL,
	[risk_scoring] INT,
	[shopper_interaction] VARCHAR(30) NOT NULL,
	[shopper_country] VARCHAR(2),
	[issuer_name] VARCHAR(256),
	[issuer_id] VARCHAR(30),
	[issuer_country] VARCHAR(2),
	[shopper_email] VARCHAR(256),
	[shopper_reference] VARCHAR(256), 
	[3d_directory_response] VARCHAR(1),
	[3d_authentication_response] VARCHAR(1),
	[cvc2_response] VARCHAR(1),
	[avs_response] VARCHAR(2),
	[acquirer_response] VARCHAR(30),
	[raw_acquirer_response] text,
	[authorisation_code] VARCHAR(50),
	[acquirer_reference] text,
	[payment_method_variant] VARCHAR(32),
	[payment_requester_type] VARCHAR(10), -- 'autorescue'
    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL
)

GO
CREATE TRIGGER [dbo].[trgAfterUpdatePaymentsReceived]
    ON [dbo].[payments_received]
    FOR UPDATE
    AS
    UPDATE [dbo].[payments_received]
        SET [updated] = GETUTCDATE()
        FROM [payments_received] t
        INNER JOIN inserted i 
			ON (
			t.psp_reference = i.psp_reference 
			)