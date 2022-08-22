CREATE TABLE [survey_responses]
(
    [survey_response_id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [survey_id] UNIQUEIDENTIFIER NOT NULL,
    [survey_name] NVARCHAR(200) NULL,
    [project_id] VARCHAR(24) NOT NULL,
    [question_id] VARCHAR(24) NOT NULL,
    [user_id] VARCHAR(24) NOT NULL,
    [customer_id] UNIQUEIDENTIFIER NULL,
    [user_emails] NVARCHAR(50) NULL,
    [response_date] DATETIME NOT NULL,
    [question_prompt] NVARCHAR(500) NULL,
    [response_value] NVARCHAR(MAX) NULL,
    [created] DATETIME DEFAULT (GETUTCDATE()),
    [updated] DATETIME DEFAULT (GETUTCDATE()),
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateSurveyResponses]
    ON [dbo].[survey_responses]
    FOR UPDATE
    AS
    UPDATE [dbo].[survey_responses]
        SET [updated] = GETUTCDATE()
        FROM [survey_responses] t
    INNER JOIN inserted i
    ON (
			t.survey_response_id = i.survey_response_id 
			)
GO

GO
CREATE INDEX [IX_survey_responses_survey_response_id] ON [dbo].[survey_responses] ([survey_response_id])