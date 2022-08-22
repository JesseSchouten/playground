CREATE TABLE [dbo].[blacklist_customers]
(
	[ customer_id ] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [ channel ] VARCHAR(3) NOT NULL, 
    [ reason ] VARCHAR(150) NOT NULL, 
    [ extra ] VARCHAR(150) NULL,
    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL
)

GO
CREATE TRIGGER [dbo].[trgAfterUpdateBlacklistCustomers]
    ON [dbo].[blacklist_customers]
    FOR UPDATE
    AS
    UPDATE [dbo].[blacklist_customers]
        SET [updated] = GETUTCDATE()
        FROM [dbo].[blacklist_customers] t
        INNER JOIN inserted i 
			ON (
			t.[ customer_id ]= i.[ customer_id ]
			)
