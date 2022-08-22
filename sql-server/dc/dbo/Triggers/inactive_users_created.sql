CREATE TRIGGER [trgAfterInsertInactiveUsers]
	ON [dbo].[inactive_users]
	FOR INSERT
	AS
	UPDATE [dbo].[inactive_users]
	  SET [ created ] = GETUTCDATE()
	  FROM Inserted i

GO

CREATE TRIGGER [trgAfterUpdateInactiveUsers]
	ON [dbo].[inactive_users]
	FOR INSERT, UPDATE
	AS
	UPDATE [dbo].[inactive_users]
	  SET [ updated ] = GETUTCDATE()
	  FROM Inserted i