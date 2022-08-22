CREATE LOGIN [datalogin] WITH password='';

GO

CREATE USER [datalogin]
	 FOR LOGIN [datalogin]
	WITH DEFAULT_SCHEMA = dbo

GO

GRANT CONNECT TO [datalogin]

GO

ALTER ROLE db_datareader ADD MEMBER [datalogin]

GO

ALTER ROLE db_datawriter ADD MEMBER [datalogin]

GO

ALTER ROLE db_ddladmin ADD MEMBER [datalogin]

GO 

GRANT EXECUTE ON SCHEMA::[dbo] TO [datalogin]