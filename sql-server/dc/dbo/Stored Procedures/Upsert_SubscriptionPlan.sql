CREATE PROCEDURE dbo.Upsert_SubscriptionPlan
(
    @id                VARCHAR (64),
    @channel          VARCHAR (8),
    @country          VARCHAR (8),
    @pause_max_days    INT,
    @system            VARCHAR (10),
    @free_trial        INT,
    @billing_cycle_type    VARCHAR (8),
    @description       VARCHAR (MAX),
    @price           REAL,
    @asset_type        INT,
    @only_available_with_promotion BIT,
    @billing_frequency SMALLINT,
    @recurring         BIT,
    @catch_up_hours    INT,
    @pause_min_days    INT,
    @number_of_supported_devices  INT,
    @currency  VARCHAR (8),
    @business_type VARCHAR (10),
    @is_downloadable   BIT,
    @only_available_for_logged_in_users BIT,
    @title VARCHAR (50),
    @start DATETIME,
    @end   DATETIME,
    @subscription_plan_type VARCHAR (8)
)
AS
BEGIN
	BEGIN TRANSACTION;
 
	UPDATE dbo.subscription_plan WITH (UPDLOCK, SERIALIZABLE) 
	SET channel = @channel,
    country = @country,
    pause_max_days = @pause_max_days,
    system = @system,
    free_trial = @free_trial,
    billing_cycle_type = @billing_cycle_type,
    description = @description,
    price = @price,
    asset_type  = @asset_type,
    only_available_with_promotion = @only_available_with_promotion,
    billing_frequency = @billing_frequency,
    recurring = @recurring,
    catch_up_hours = @catch_up_hours,
    pause_min_days = @pause_min_days,
    number_of_supported_devices = @number_of_supported_devices,
    currency = @currency,
    business_type = @business_type,
    is_downloadable = @is_downloadable ,
    only_available_for_logged_in_users = @only_available_for_logged_in_users,
    title = @title,
    start = @start,
    "end" = @end,
    subscription_plan_type = @subscription_plan_type,
    updated = CURRENT_TIMESTAMP 
	WHERE id = @id

	IF @@ROWCOUNT = 0
	BEGIN
	  INSERT INTO dbo.subscription_plan(id, channel, country,
               pause_max_days, system, free_trial, billing_cycle_type,
               description, price, asset_type, only_available_with_promotion,
               billing_frequency, recurring, catch_up_hours, pause_min_days,
               number_of_supported_devices, currency, business_type, is_downloadable,
               only_available_for_logged_in_users, title, start, "end",
               subscription_plan_type) 
	  VALUES(@id, @channel, @country,
               @pause_max_days, @system, @free_trial, @billing_cycle_type,
               @description, @price, @asset_type, @only_available_with_promotion,
               @billing_frequency, @recurring, @catch_up_hours, @pause_min_days,
               @number_of_supported_devices, @currency, @business_type, @is_downloadable,
               @only_available_for_logged_in_users, @title, @start, @end,
               @subscription_plan_type) 
	END

	COMMIT TRANSACTION
END