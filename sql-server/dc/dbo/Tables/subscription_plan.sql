CREATE TABLE [dbo].[subscription_plan] (
    [id]                VARCHAR (64) NOT NULL PRIMARY KEY,
    [channel]           VARCHAR (3)  NULL,
    [country]           VARCHAR (2) NULL,
    [pause_max_days]    INT NULL,
    [system]            VARCHAR (10) NULL,
    [free_trial]        INT NULL,
    [billing_cycle_type]     VARCHAR (8)  NULL,
    [description]       VARCHAR (MAX) NULL,
    [price]            MONEY NOT NULL,
    [asset_type]        INT NULL,
    [only_available_with_promotion] BIT NULL,
    [billing_frequency] SMALLINT     NULL,
    [recurring]         BIT NULL,
    [catch_up_hours]    INT NULL,
    [pause_min_days]    INT NULL,
    [number_of_supported_devices]   INT NULL,
    [currency]  VARCHAR (8) NULL,
    [business_type] VARCHAR (10) NULL,
    [is_downloadable]   BIT NULL,
    [only_available_for_logged_in_users] BIT NULL,
    [title] VARCHAR (50) NULL,
    [start] DATETIME NULL,
    [end]   DATETIME NULL,
    [subscription_plan_type] VARCHAR (8) NULL,
    [created]           DATETIME     DEFAULT (getdate()) NULL,
    [updated]           DATETIME     DEFAULT (getdate()) NULL,
    -- Not asset types, payment_providers, countries
    -- Also left out asset_ids and promotions they are NULL for all subscription plans
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSubscriptionPlan]
    ON [dbo].[subscription_plan]
    FOR UPDATE
    AS
    UPDATE [dbo].[subscription_plan]
        SET [updated] = GETUTCDATE()
        FROM [dbo].[subscription_plan] t
        INNER JOIN inserted i 
			ON (
			t.id = i.id 
			)