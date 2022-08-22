CREATE TABLE [dbo].[subscriptions]
(
	[subscription_id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY, 
    [customer_id] UNIQUEIDENTIFIER NOT NULL,
    [channel] VARCHAR(3) NULL,
    [country] VARCHAR (2) NULL,
    [subscription_plan_id] NVARCHAR(50) NOT NULL,
    [subscription_create_date] DATETIME NOT NULL,
    [subscription_start] DATETIME NOT NULL,
    [subscription_end] DATE NOT NULL,
    [subscription_paused_date] DATETIME NULL,
    [subscription_resumable_days] INT NULL,
    [state] VARCHAR(15) NULL,
    [recurring_enabled] BIT NULL,
    [payment_provider] VARCHAR(15) NULL,
    [free_trial] INT NULL,
    [notes] VARCHAR(MAX) NULL,
    [is_pausable] BIT NULL,
    [is_resumable] BIT NULL,
    [new_plan_id] NVARCHAR(50) NULL,
    [first_payment_date] DATETIME NULL,
    [cancel_date] DATETIME NULL,
    [switch_date] DATETIME NULL,
    [switch_from] UNIQUEIDENTIFIER NULL,
    [switch_to] UNIQUEIDENTIFIER NULL,
    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL
);

GO
CREATE INDEX [IX_subscriptions_subscription_create_date] ON [dbo].[subscriptions] ([subscription_create_date]);

GO
CREATE INDEX [IX_subscriptions_channel] ON [dbo].[subscriptions] ([channel]);

GO
CREATE INDEX [IX_subscriptions_country] ON [dbo].[subscriptions] ([country]);

GO
CREATE NONCLUSTERED INDEX [IX_subscriptions_state_channel] ON [dbo].[subscriptions] ([state], [channel]) INCLUDE ([country], [customer_id], [first_payment_date], [recurring_enabled], [subscription_create_date], [subscription_plan_id]) WITH (ONLINE = ON)

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSubscriptions]
    ON [dbo].[subscriptions]
    FOR UPDATE
    AS
    UPDATE [dbo].[subscriptions]
        SET [updated] = GETUTCDATE()
        FROM [dbo].[subscriptions] t
        INNER JOIN inserted i 
			ON (
			t.subscription_id = i.subscription_id 
			)
GO
CREATE TRIGGER [customers_country_upsert_on_subscription]
	ON [dbo].[subscriptions]
	AFTER INSERT, UPDATE
    AS
    BEGIN
       SET NOCOUNT ON;
 
       DECLARE @customer_id UNIQUEIDENTIFIER
       DECLARE @country VARCHAR(2)
 
       SELECT @customer_id = INSERTED.customer_id, @country = INSERTED.country
       FROM INSERTED
        IF(SELECT country from customers where customer_id = @customer_id) != @country AND @country is not null
            BEGIN
            UPDATE [dbo].[customers]
                SET [country]= @country
                WHERE customer_id = @customer_id
            END
END



