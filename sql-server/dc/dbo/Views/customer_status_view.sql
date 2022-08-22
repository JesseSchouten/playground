CREATE VIEW [dbo].[customer_status_view]
	AS SELECT 
        [c].[customer_id] AS [external_id], 
		[c].[email],
		[c].[create_date] as registration_date, 
		[c].[channel], 
		[c].[first_name], 
		[c].[last_name],
		
		CASE WHEN [s].[recurring_enabled]=1 THEN 'true' ELSE 'false' END as [is_recurring], 
		[s].[subscription_create_date] as current_subscription_create_date,
		[s].[subscription_end] as subscription_end_date,
		[s].[subscription_plan_id] as subscription_plan_id, 
        [s].[first_payment_date] as first_payment_date,
		CASE WHEN [id] LIKE '%basic%' THEN 'basic' ELSE 'premium' END as business_type,
		[p].[price] as subscription_plan_price,
		CASE WHEN [p].[country] IS NOT NULL THEN [p].[country] ELSE [c].[registration_country] END as country,

		/* This is based on: subscription pause date, first payment date, subscription end date, notes, and recurring field*/ 
        IIF([s].[subscription_paused_date] IS NOT NULL AND [s].[state] != 'onhold', 'paused', 
		IIF([s].[subscription_create_date] IS NULL OR [s].[state] = 'pending', 'prospect',
		IIF(RIGHT(notes , 30) like '%Subscription extended%' AND [s].[subscription_end] > GETUTCDATE(), 'voucher',
		IIF([c].[first_payment_date] IS NULL AND [s].[subscription_end] > GETUTCDATE() AND [s].[recurring_enabled] > 0, 'trial', 
		IIF([s].[recurring_enabled] > 0 AND [s].[subscription_end] > GETUTCDATE(), 'paid', 
        'churned'))))) AS [status]

      -- We want all customers and subscription combinations, and if no subscription is found, then make a 'NULL' subscription
      FROM [dbo].[customers] AS [c]
      LEFT OUTER JOIN [subscriptions] AS [s] ON [s].[customer_id] = [c].[customer_id]
      LEFT OUTER JOIN [subscription_plan] AS [p] ON [p].[id] = [s].[subscription_plan_id]

      WHERE
         -- Take only NFN and LOV customers
        ([c].[channel] = 'nfn' OR [c].[channel] = 'lov')

        -- If multiple subscriptions per customer are found, take latest
        AND ([s].[subscription_id] IS NULL OR [s].[subscription_id] = (
          SELECT TOP(1) [t].[subscription_id] FROM [subscriptions] AS [t]
            WHERE [t].[customer_id] = [c].[customer_id]
            ORDER BY [t].[subscription_create_date] DESC
          ))

        -- Take only prospects of latest 14 days and subscriptions which were active in last 30 days
        AND (
          (([s].[state] IS NULL OR [s].[state] = 'pending') AND [c].[create_date] > DATEADD(DAY, -14, GETUTCDATE()))
          OR ([s].[state] != 'pending' AND [s].[subscription_end] > DATEADD(DAY, -30, GETUTCDATE()))
        )