CREATE TABLE [dbo].[customer_histogram]
(

	[channel] VARCHAR(3) NOT NULL,
	[cohort] CHAR(7) NOT NULL,
	[age] INT NOT NULL,
	[recurring] INT NOT NULL,
	[cancelled] INT NOT NULL,
	[total] INT NOT NULL,
	[older_than] INT NOT NULL,
	[churn] REAL NOT NULL,
    [created]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    [updated]                DATETIME     DEFAULT (GETUTCDATE()) NULL,
    PRIMARY KEY CLUSTERED ([channel] ASC, [cohort] ASC, [age] ASC)
);

GO
CREATE TRIGGER [dbo].[trgAfterUpdateCustomerHistogram]
    ON [dbo].[customer_histogram]
    FOR UPDATE
    AS
    UPDATE [dbo].[customer_histogram]
        SET [updated] = GETUTCDATE()
        FROM [customer_histogram] t
        INNER JOIN inserted i 
			ON (
			t.channel = i.channel
			AND t.cohort = i.cohort
			AND t.age = i.age
			)