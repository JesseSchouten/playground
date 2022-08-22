CREATE VIEW [dbo].[problematic_customers_view]
	AS SELECT
		t.customer_id,
		c.subscription_id,
		c.subscription_create_date,
		c.subscription_end,
		s.number_of_subscriptions,
		t.received,
		t.chargebacks,
		t.refunds
	FROM (
		SELECT
            [customer_id],
            SUM([net_received]) AS [received],
            SUM(CAST([has_chargeback] AS NUMERIC)) AS [chargebacks],
            SUM(CAST([has_refund] AS NUMERIC)) AS [refunds]
		FROM [dbo].[customer_month_states]
		GROUP BY [customer_id]
	) AS t
	LEFT JOIN (
		SELECT
            [customer_id],
            COUNT(1) AS [number_of_subscriptions]
		FROM [dbo].[subscriptions]
		WHERE [state] != 'pending'
		GROUP BY [customer_id]
	) AS s ON s.[customer_id] = t.[customer_id]
	RIGHT JOIN (
		SELECT
            [customer_id],
            [subscription_id],
            [subscription_create_date],
            [subscription_end]
		FROM [dbo].[subscriptions]
		WHERE [subscription_end] > GETDATE()
	) AS c ON c.[customer_id] = t.[customer_id]
	WHERE
		s.number_of_subscriptions > 1
		AND t.received < -1