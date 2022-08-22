CREATE TABLE [survey_questions_silver]
(
    [id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [question_id] VARCHAR(24) NOT NULL,
    [survey_id] VARCHAR(24) NOT NULL,
    [survey_name] NVARCHAR(200) NULL,
    [project_id] VARCHAR(24) NOT NULL,
    [project_name] NVARCHAR(200) NULL,
    [version] INT NOT NULL,
    [channel] VARCHAR(8) NOT NULL,
    [country] VARCHAR(8) NOT NULL,
    [language] VARCHAR(2) NULL,
    [question_type] VARCHAR(50) NULL,
    [question_prompt] NVARCHAR(500) NULL,
    [translated_question_prompt] NVARCHAR(500) NULL,
    [created] DATETIME DEFAULT (GETUTCDATE()),
    [updated] DATETIME DEFAULT (GETUTCDATE())
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSurveyQuestionsSilver]
    ON [dbo].[survey_questions_silver]
    FOR UPDATE
    AS
    UPDATE [dbo].[survey_questions_silver]
        SET [updated] = GETUTCDATE()
        FROM [survey_questions_silver] t
    INNER JOIN inserted i
    ON (
			t.question_id = i.question_id 
			)
GO

GO
CREATE INDEX [IX_survey_questions_silver_question_id] ON [dbo].[survey_questions_silver] ([question_id])