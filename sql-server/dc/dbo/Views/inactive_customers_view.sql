CREATE VIEW [dbo].[inactive_customers_view]
    AS SELECT 
        c.customer_id, 
        c.channel, 
        c.first_name, 
        c.last_name, 
        c.registration_country, 
        c.create_date, 
        c.activation_date, 
        c.last_login, 
        c.facebook_id, 
        c.email, 
        c.first_payment_date, 
        s.subscription_id, 
        s.subscription_plan_id, 
        s.channel AS subscription_channel, 
        s.recurring_enabled, 
        s.subscription_create_date, 
        s.subscription_start, 
        s.subscription_end, 
        s.first_payment_date AS subscription_first_payment_date
    FROM dbo.customers AS c
        INNER JOIN (
            SELECT * FROM (
                SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY subscription_end DESC) AS row_number
                FROM [dbo].[subscriptions]
                WHERE [state] = 'activated'
            ) AS t WHERE t.row_number = 1
        ) AS s ON c.customer_id = s.customer_id
    WHERE s.subscription_end < GETDATE()
