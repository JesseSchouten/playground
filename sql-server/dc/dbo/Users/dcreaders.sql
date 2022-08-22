﻿CREATE USER [Data readers] FROM EXTERNAL PROVIDER
	WITH DEFAULT_SCHEMA = dbo

GO

GRANT CONNECT TO [Data readers]

GO

ALTER ROLE db_datareader ADD MEMBER [Data readers]