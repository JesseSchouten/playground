CREATE LOGIN githublogin WITH password='';

GO

CREATE USER [githublogin]
	 FOR LOGIN [githublogin]
	WITH DEFAULT_SCHEMA = dbo

GO

GRANT CONNECT TO [githublogin]

GO

ALTER ROLE db_owner ADD MEMBER [githublogin]