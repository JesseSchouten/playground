CREATE TABLE [questions]
(
    [question_id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [survey_id] UNIQUEIDENTIFIER NOT NULL,
    [survey_name] NVARCHAR(200) NULL,
    [project_id] VARCHAR(24) NOT NULL,
    [question_type] VARCHAR(50) NULL,
    [question_prompt] NVARCHAR(500) NULL,
    [question_options_labels] NVARCHAR(MAX) NULL,
    [question_options_custom_labels] NVARCHAR(MAX) NULL,
    [created] DATETIME DEFAULT (GETUTCDATE()),
    [updated] DATETIME DEFAULT (GETUTCDATE())
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateQuestions]
    ON [dbo].[questions]
    FOR UPDATE
    AS
    UPDATE [dbo].[questions]
        SET [updated] = GETUTCDATE()
        FROM [questions] t
    INNER JOIN inserted i
    ON (
			t.question_id = i.question_id 
			)
GO

GO
CREATE INDEX [IX_questions_question_id] ON [dbo].[questions] ([question_id])