CREATE TABLE [dbo].[viewing] (
    [timestamp]              DATETIME     NOT NULL,
    [channel] VARCHAR(3) NULL,
	[country] VARCHAR(2) NULL,
    [video_id]               VARCHAR (64) NULL,
    [video_type]             VARCHAR (32) NULL,
    [platform]               VARCHAR (32) NULL,
    [video_playtime_minutes] INT          NULL,
    [created]                DATETIME     DEFAULT (getdate()) NULL,
    [updated]                DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [UK_viewing] UNIQUE NONCLUSTERED ([timestamp] ASC, [channel] ASC, [country] ASC, [video_id] ASC, [video_type] ASC, [platform] ASC)
);

GO
CREATE CLUSTERED INDEX [CI_viewing]
    ON [dbo].[viewing]([timestamp] ASC, [channel] ASC, [country] ASC, [video_id] ASC, [platform] ASC);

