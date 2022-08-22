CREATE TABLE [dbo].[daily_ad_report]
(
  [date] DATETIME NOT NULL,
  [channel] VARCHAR(3) NOT NULL,
  [country] VARCHAR(2) NOT NULL,
  [social_channel] VARCHAR(32) NOT NULL,
  [account_id] VARCHAR(36) NOT NULL,
  [account_name] VARCHAR(110),
  [campaign_id] VARCHAR(36) NOT NULL,
  [campaign_name] VARCHAR(110),
  [adset_id] VARCHAR(36) NOT NULL,
  [adset_name] VARCHAR(110),
  [ad_id] VARCHAR(36) NOT NULL,
  [ad_name] VARCHAR(200),
  [time_zone] VARCHAR(64) NOT NULL,
  [currency] VARCHAR(5) NOT NULL,
  [paid_impressions] int DEFAULT 0,
  [paid_clicks] int DEFAULT 0,
  [costs] SMALLMONEY DEFAULT 0,
  [created] DATETIME DEFAULT (GETUTCDATE()),
  [updated] DATETIME DEFAULT (GETUTCDATE()),
  PRIMARY KEY CLUSTERED ([date] ASC, [channel] ASC, [country] ASC, [social_channel] ASC, [account_id] ASC, [campaign_id] ASC, [adset_id] ASC, [ad_id])
)

GO
CREATE INDEX [IX_daily_ad_report_channel] ON [dbo].[daily_ad_report] ([channel]);

GO
CREATE INDEX [IX_daily_ad_report_country] ON [dbo].[daily_ad_report] ([country]);

GO
CREATE NONCLUSTERED INDEX [IX_daily_ad_channel_social_channel] ON [dbo].[daily_ad_report] ([channel], [social_channel]) INCLUDE ([ad_name], [adset_name], [campaign_name], [costs], [paid_clicks], [paid_impressions]) WITH (ONLINE = ON)

GO
CREATE TRIGGER [dbo].[trgAfterUpdateDailyAdReport]
    ON [dbo].[daily_ad_report]
    FOR UPDATE
    AS
    UPDATE [dbo].[daily_ad_report]
        SET [updated] = GETUTCDATE()
        FROM [daily_ad_report] t
        INNER JOIN inserted i 
			ON (
			t.[date] = i.[date]
			AND t.channel = i.channel
			AND t.country = i.country
            AND t.social_channel = i.social_channel
            AND t.account_id = i.account_id
            AND t.campaign_id = i.campaign_id
            AND t.adset_id = i.adset_id
            AND t.ad_id = i.ad_id
			)

