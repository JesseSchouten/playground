/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
IF (NOT EXISTS(SELECT * FROM dbo.month_targets WHERE month>='2021-01-01'and month<'2022-01-01'and channel='lov'))  
BEGIN  
    :r .\2021-lov-targets-insert.sql	
END
IF (NOT EXISTS(SELECT * FROM dbo.month_targets WHERE month>='2021-01-01'and month<'2022-01-01'and channel='nfn'))  
BEGIN  
    :r .\2021-nfn-targets-insert.sql	
END