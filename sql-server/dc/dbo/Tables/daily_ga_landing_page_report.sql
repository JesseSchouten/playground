CREATE TABLE [dbo].[daily_ga_landing_page_report]
(
  [date] DATE NOT NULL,
  [account_id] INT NOT NULL,
  [property_id] VARCHAR(20) NOT NULL,
  [property_name] text NOT NULL,
  [view_id] INT NOT NULL,
  [view_name] text NOT NULL,
  [view_timezone] text NULL,
  [channel] VARCHAR(3) NOT NULL,
  [country] VARCHAR(3) NOT NULL,
  [segment] VARCHAR(50) NOT NULL,
  [source] VARCHAR(60) NOT NULL,
  [medium] VARCHAR(50) NOT NULL,
  [campaign_name] VARCHAR(110) NOT NULL,
  [ad_name] VARCHAR(200) NOT NULL,
  [sessions] INT NULL,
  [new_users] INT NULL,
  [pageviews] INT NULL,
  [bounces] INT NULL,
  [landing] INT NULL,
  [register] INT NULL,
  [choose_plan] INT NULL,
  [payment] INT NULL,
  [succes] INT NULL,
  [created] DATETIME DEFAULT (GETUTCDATE()),
  [updated] DATETIME DEFAULT (GETUTCDATE()),
  PRIMARY KEY CLUSTERED (
    [date] ASC, 
    [account_id] ASC, 
    [property_id] ASC, 
    [view_id] ASC, 
    [channel] ASC, 
    [country] ASC, 
    [segment] ASC, 
    [source] ASC, 
    [medium] ASC, 
    [campaign_name] ASC, 
    [ad_name] ASC)
)

GO
CREATE TRIGGER [dbo].[trgAfterUpdateDailyGaLandingPageReport]
    ON [dbo].[daily_ga_landing_page_report]
    FOR UPDATE
    AS
    UPDATE [dbo].[daily_ga_landing_page_report]
        SET [updated] = GETUTCDATE()
        FROM [daily_ga_landing_page_report] t
  INNER JOIN inserted i
  ON (
			t.[date] = i.[date]
    AND t.[channel] = i.[channel]
    AND t.[country] = i.[country]
    AND t.[account_id] = i.[account_id]
    AND t.[property_id] = i.[property_id]
    AND t.[view_id] = i.[view_id]
    AND t.[segment] = i.[segment]
    AND t.[source] = i.[source]
    AND t.[medium] = i.[medium]
    AND t.[campaign_name] = i.[campaign_name]
    AND t.[ad_name] = i.[ad_name]
			)

