CREATE TABLE [dbo].[landingpages_report]
(
  -- pivot columns
  [date] DATETIME NOT NULL,
  [channel] VARCHAR(3) NOT NULL,
  [country] VARCHAR(2) NOT NULL,
  [source] text NOT NULL,
  [medium] text NOT NULL,
  [campaign_name] VARCHAR(110) NOT NULL,
  [marketing_channel] VARCHAR(32) NOT NULL,

  -- aggregates
  [costs] SMALLMONEY DEFAULT 0,
  [impressions] INT NOT NULL DEFAULT 0,
  [clicks] INT NOT NULL DEFAULT 0,
  [registers] INT NOT NULL DEFAULT 0,
  [trials] INT NOT NULL DEFAULT 0,

  -- meta
  [created] DATETIME DEFAULT (GETUTCDATE()),
  [updated] DATETIME DEFAULT (GETUTCDATE()),

  -- key
  PRIMARY KEY CLUSTERED (
    [date] ASC,
    [channel] ASC,
    [country] ASC,
    [campaign_name] ASC,
    [marketing_channel] ASC
  )
)

GO
CREATE TRIGGER [dbo].[trgAfterUpdateLandingpagesReport]
  ON [dbo].[landingpages_report]
  FOR UPDATE
  AS UPDATE [dbo].[landingpages_report]
    SET [updated] = GETUTCDATE()
    FROM [landingpages_report] t
    INNER JOIN inserted i ON (
      t.[date] = i.[date]
      AND t.[channel] = i.[channel]
      AND t.[country] = i.[country]
      AND t.[campaign_name] = i.[campaign_name]
      AND t.[marketing_channel] = i.[marketing_channel]
    )
