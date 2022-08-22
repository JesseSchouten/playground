CREATE TABLE [surveys_silver]
(
    [id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [survey_id] VARCHAR(24) NOT NULL,
    [survey_name] NVARCHAR(200) NULL,
    [version] INT NOT NULL,
    [channel] VARCHAR(8) NOT NULL,
    [country] VARCHAR(8) NOT NULL,
    [language] VARCHAR(2) NULL,
    [project_id] VARCHAR(24) NOT NULL,
    [project_name] NVARCHAR(200) NULL,
    [question_ids] VARCHAR(max) NULL,
    [survey_created_at] DATETIME NULL,
    [created] DATETIME DEFAULT (GETUTCDATE()),
    [updated] DATETIME DEFAULT (GETUTCDATE()),
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSurveySilver]
    ON [dbo].[surveys_silver]
    FOR UPDATE
    AS

    UPDATE [dbo].[surveys_silver]
        SET [updated] = GETUTCDATE()
        FROM [surveys_silver] t
    INNER JOIN inserted i
    ON (
			t.survey_id = i.survey_id 
			)
GO

GO
CREATE INDEX [IX_surveys_silver_survey_id] ON [dbo].[surveys_silver] ([survey_id])
CREATE INDEX [IX_surveys_silver_id] ON [dbo].[surveys_silver] ([id])