CREATE VIEW [dbo].[active_customers_view]
	AS SELECT 
    dbo.customers.customer_id, 
    dbo.customers.channel, 
    dbo.customers.first_name, 
    dbo.customers.last_name, 
    dbo.customers.registration_country, 
    dbo.customers.create_date, 
    dbo.customers.activation_date,
    dbo.customers.last_login, 
    dbo.customers.facebook_id, 
    dbo.customers.email, 
    dbo.customers.first_payment_date, 
    dbo.subscriptions.subscription_id, 
    dbo.subscriptions.subscription_plan_id, 
    dbo.subscriptions.channel AS subscription_channel, 
    dbo.subscriptions.recurring_enabled, 
    dbo.subscriptions.subscription_create_date, 
    dbo.subscriptions.subscription_start, 
    dbo.subscriptions.subscription_end, 
    dbo.subscriptions.first_payment_date AS subscription_first_payment_date
FROM dbo.customers 
    INNER JOIN dbo.subscriptions ON dbo.customers.customer_id = dbo.subscriptions.customer_id
   
WHERE  (dbo.subscriptions.subscription_end >= GETDATE())
