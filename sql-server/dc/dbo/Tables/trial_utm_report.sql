CREATE TABLE [dbo].[trial_utm_report]
(
    [date] DATETIME NOT NULL, 
    [subscription_id] UNIQUEIDENTIFIER NOT NULL,
    [channel] VARCHAR(3) NOT NULL,
    [country] VARCHAR(2) NOT NULL,
    [marketing_channel] VARCHAR(32) NULL,
    [source] VARCHAR(110) NULL,
    [source_click] VARCHAR(110) NULL,
    [medium] VARCHAR(110) NULL,
    [campaign] VARCHAR(110) NULL,
    [content] VARCHAR(110) NULL,

    -- meta
    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL,

    -- key
    PRIMARY KEY CLUSTERED (
    [date] ASC,
    [subscription_id] ASC
  )
)

GO
CREATE INDEX [IX_trial_utm_report_date_sub_id] ON [dbo].[trial_utm_report] ([date], [subscription_id]);


GO
CREATE TRIGGER [dbo].[trgAfterUpdateTrialUtmReport]
    ON [dbo].[trial_utm_report]
    FOR UPDATE
    AS
    UPDATE [dbo].[trial_utm_report]
        SET [updated] = GETUTCDATE()
        FROM [dbo].[trial_utm_report] t
        INNER JOIN inserted i 
			ON (
            t.date = i.date AND
			t.subscription_id = i.subscription_id 
			)


