CREATE TABLE [survey_question_labels_silver]
(
    [id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [question_id] VARCHAR(24) NOT NULL,
    [survey_id] VARCHAR(24) NOT NULL,
    [project_id] VARCHAR(24) NOT NULL,
    [version] INT NOT NULL,
    [language] VARCHAR(2) NULL,
    [channel] VARCHAR(8) NOT NULL,
    [country] VARCHAR(8) NOT NULL,
    [key] VARCHAR(50) NULL,
    [original_value] NVARCHAR(500) NULL,
    [translated_value] NVARCHAR(500) NULL,
    [created] DATETIME DEFAULT (GETUTCDATE()),
    [updated] DATETIME DEFAULT (GETUTCDATE())
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSurveyQuestionLabelsSilver]
    ON [dbo].[survey_question_labels_silver]
    FOR UPDATE
    AS
    UPDATE [dbo].[survey_question_labels_silver]
        SET [updated] = GETUTCDATE()
        FROM [question_labels] t
    INNER JOIN inserted i
    ON (
			t.question_id = i.question_id 
			)
GO

GO
CREATE INDEX [IX_survey_question_labels_silver_question_id] ON [dbo].[survey_question_labels_silver] ([question_id])