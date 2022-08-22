CREATE TABLE [dbo].[ga_custom_goals]
(
	[account_name] text NOT NULL,
	[account_id] int NOT NULL,
	[property_name] text NOT NULL,
	[property_id] VARCHAR(20) NOT NULL,
	[view_id] int NOT NULL,
	[view_name] text NOT NULL,
	[view_timezone] VARCHAR(64) NOT NULL,
	[goals_index] int NOT NULL,
	[goals_name] text NOT NULL,
	[goal_value] int NOT NULL,
	[goal_active_status] bit NOT NULL,
	[goal_type] VARCHAR(64) NOT NULL,
	[goal_created_date] DATETIME NOT NULL,
	[goal_updated_date] DATETIME NOT NULL,
	[start_date] DATETIME NOT NULL,
	[end_date] DATETIME,
	[created] DATETIME DEFAULT (GETUTCDATE()),
	[updated] DATETIME DEFAULT (GETUTCDATE())
)

