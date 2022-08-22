CREATE TABLE [dbo].[switches]
(
	[subscription_id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY, 
    [customer_id] UNIQUEIDENTIFIER NOT NULL, 
    [new_subscription_id] UNIQUEIDENTIFIER NULL, 
    [new_subscription_plan] VARCHAR(64) NULL, 
    [initialization_date] DATETIME NULL, 
    [activation_date] DATETIME NULL,

    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSwitches]
    ON [dbo].[switches]
    FOR UPDATE
    AS
    UPDATE [dbo].[switches]
        SET [updated] = GETUTCDATE()
        FROM [dbo].[switches] t
        INNER JOIN inserted i 
			ON (
			t.subscription_id = i.subscription_id 
			)