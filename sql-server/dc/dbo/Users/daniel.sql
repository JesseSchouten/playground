CREATE LOGIN [daniel] WITH password='';

GO

CREATE USER [daniel]
	 FOR LOGIN [daniel]
	WITH DEFAULT_SCHEMA = dbo

GO

GRANT CONNECT TO [daniel]

GO

ALTER ROLE db_datareader ADD MEMBER [daniel]