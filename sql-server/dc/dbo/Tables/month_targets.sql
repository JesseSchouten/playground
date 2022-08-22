CREATE TABLE [dbo].[month_targets]
(
  [month] DATETIME NOT NULL,
  [channel] VARCHAR(8) NOT NULL,
  [country] VARCHAR(8) NOT NULL,
  [nr_trials] INT NULL DEFAULT 0,
  [nr_reconnects] INT NULL DEFAULT 0,
  [nr_paid_customers] INT NULL DEFAULT 0,
  [nr_active_customers] INT NULL DEFAULT 0,
  [created] DATETIME DEFAULT (GETUTCDATE()),
  [updated] DATETIME DEFAULT (GETUTCDATE()),
  PRIMARY KEY CLUSTERED ([month] ASC, [channel] ASC, [country] ASC)
);

GO
	CREATE TRIGGER [dbo].[trgAfterUpdateMonthTargets]
		ON [dbo].[month_targets]
		FOR UPDATE
		AS
		UPDATE [dbo].[month_targets]
			SET [updated] = GETUTCDATE()
			FROM [month_targets] t
			INNER JOIN inserted i 
				ON (
				t.month = i.month 
				AND t.channel = i.channel
				AND t.country = i.country
				)

GO
	CREATE TRIGGER [trgAfterInsertMonthTargets]
		ON [dbo].[month_targets]
		FOR INSERT
		AS
		UPDATE [dbo].[month_targets]
		  SET [created] = GETUTCDATE()
		  FROM Inserted i
