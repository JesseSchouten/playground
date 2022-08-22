﻿CREATE USER [aks-sql] FROM EXTERNAL PROVIDER
	WITH DEFAULT_SCHEMA = dbo

GO

GRANT CONNECT TO [aks-sql]

GO

ALTER ROLE db_datareader ADD MEMBER [aks-sql]

GO

ALTER ROLE db_datawriter ADD MEMBER [aks-sql]