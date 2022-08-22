CREATE TABLE [dbo].[customers]
(
    [customer_id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [channel] VARCHAR(3) NULL,
	[country] VARCHAR(2) NULL,
    [first_name] NVARCHAR(50) NULL, 
    [last_name] NVARCHAR(50) NULL, 
    [registration_country] CHAR(2) NULL, 
    [create_date] DATETIME NULL, 
    [activation_date] DATETIME NULL, 
    [last_login] VARCHAR(23) NULL, 
    [facebook_id] VARCHAR(20) NULL, 
    [email]       NVARCHAR(50) NULL,
    [first_payment_date] DATETIME NULL,
    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL
);

GO
CREATE INDEX [IX_customers_create_date] ON [dbo].[customers] ([create_date])

GO
CREATE TRIGGER [dbo].[trgAfterUpdateCustomers]
    ON [dbo].[customers]
    FOR UPDATE
    AS
    UPDATE [dbo].[customers]
        SET [updated] = GETUTCDATE()
        FROM [customers] t
        INNER JOIN inserted i 
			ON (
			t.customer_id = i.customer_id 
			)
