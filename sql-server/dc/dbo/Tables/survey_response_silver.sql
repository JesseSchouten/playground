CREATE TABLE [survey_responses_silver]
(
    [id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [survey_response_id] VARCHAR(24) NOT NULL,
    [survey_id] VARCHAR(24) NOT NULL,
    [survey_name] NVARCHAR(200) NULL,
    [project_id] VARCHAR(24) NOT NULL,
    [project_name] NVARCHAR(200) NULL,
    [question_id] VARCHAR(24) NOT NULL,
    [version] INT NOT NULL,
    [channel] VARCHAR(8) NOT NULL,
    [country] VARCHAR(8) NOT NULL,
    [question_language] VARCHAR(2) NULL,
    [question_prompt] NVARCHAR(500) NULL,
    [question_prompt_translated] NVARCHAR(500) NULL,
    [customer_id] UNIQUEIDENTIFIER NULL,
    [user_emails] NVARCHAR(50) NULL,
    [response_date] DATETIME NOT NULL,
    [response_value] NVARCHAR(MAX) NULL,
    [response_value_translated] NVARCHAR(MAX) NULL,
    [response_language] VARCHAR(2) NULL,
    [response_language_confidence] DECIMAL NULL,
    [created] DATETIME DEFAULT (GETUTCDATE()),
    [updated] DATETIME DEFAULT (GETUTCDATE()),
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSurveyResponsesSilver]
    ON [dbo].[survey_responses]
    FOR UPDATE
    AS
    UPDATE [dbo].[survey_responses_silver]
        SET [updated] = GETUTCDATE()
        FROM [survey_responses_silver] t
    INNER JOIN inserted i
    ON (
			t.survey_response_id = i.survey_response_id 
			)
GO

GO
CREATE INDEX [IX_survey_responses_silver_survey_response_id] ON [dbo].[survey_responses_silver] ([survey_response_id])