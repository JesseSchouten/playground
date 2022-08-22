CREATE TABLE [surveys]
(
    [survey_id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [survey_name] NVARCHAR(200) NULL,
    [project_id] VARCHAR(24) NOT NULL,
    [question_ids] VARCHAR(max) NULL,
    [survey_created_at] DATETIME NULL,
    [created] DATETIME DEFAULT (GETUTCDATE()),
    [updated] DATETIME DEFAULT (GETUTCDATE()),
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSurvey]
    ON [dbo].[surveys]
    FOR UPDATE
    AS
    UPDATE [dbo].[surveys]
        SET [updated] = GETUTCDATE()
        FROM [surveys] t
    INNER JOIN inserted i
    ON (
			t.survey_id = i.survey_id 
			)
GO

GO
CREATE INDEX [IX_surveys_survey_id] ON [dbo].[surveys] ([survey_id])
