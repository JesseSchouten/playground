CREATE VIEW [dbo].[hourly_trials_report]
WITH SCHEMABINDING
	AS SELECT 
	FORMAT(createdDateInCET, 'yyyy-MM-dd HH:00:00' ) AS [date],
	DATEPART(hour, createdDateInCET) as [hour],
	sub.channel, 
	sub.country,
    COUNT(CASE WHEN (cust.first_payment_date > sub.subscription_create_date) or (cust.first_payment_date IS NULL) THEN 1 END) as nr_trials,
	COUNT(CASE WHEN (cust.first_payment_date < sub.subscription_create_date) and (cust.first_payment_date IS NOT NULL) THEN 1 END) as nr_reconnects,
	COUNT(CASE WHEN sub.first_payment_date IS NOT NULL THEN 1 END) as nr_trails_reconects_became_paid,
	MAX(createdDateInCet) as last_trial_time_in_hour

FROM [dbo].[subscriptions] as sub 

LEFT JOIN 
dbo.customers as cust 
ON sub.customer_id = cust.customer_id

LEFT JOIN 
dbo.switches as switch 
ON sub.subscription_id = switch.new_subscription_id

LEFT JOIN 
(SELECT subscription_id, 
CONVERT(DATETIME, CAST(REPLACE(subscription_create_date AT TIME ZONE 'Central European Standard Time', '+', '-') as DATETIMEOFFSET), 1)
       AS createdDateInCet
FROM dbo.subscriptions) as createdDateInCET 
on sub.subscription_id = createdDateInCET.subscription_id

WHERE state != 'pending' and state IS NOT NULL and switch.new_subscription_id IS NULL

GROUP BY FORMAT(createdDateInCET, 'yyyy-MM-dd HH:00:00' ),
	   DATEPART(hour, createdDateInCET),
	   sub.channel, 
	   sub.country