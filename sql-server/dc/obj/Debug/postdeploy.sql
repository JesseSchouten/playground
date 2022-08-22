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
INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'lov', 'NL', 2250   ,   20850	)
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'lov', 'BE', 150    ,   1450	)
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'lov', 'NO', 750    ,   2100	)
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'lov', 'SE', 1350   ,   3825	)
    
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'lov', 'NL', 2250   ,   20710  )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'lov', 'BE', 250    ,   1459   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'lov', 'NO', 1250   ,   2967   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'lov', 'SE', 2750   ,   5223   )        
    
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'lov', 'NL', 2600   ,   22086  )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'lov', 'BE', 400    ,   1834   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'lov', 'NO', 2000   ,   5482   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'lov', 'SE', 3000   ,   9095   )         
    
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'lov', 'NL', 5450   ,   22789  )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'lov', 'BE', 650    ,   1895   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'lov', 'NO', 3000   ,   5291   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'lov', 'SE', 3500   ,   8610   )         
    
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'lov', 'NL', 5500   ,   26076  )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'lov', 'BE', 1000   ,   2434   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'lov', 'NO', 3000   ,   6437   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'lov', 'SE', 4850   ,   9318   )         
    
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'lov', 'NL', 7000   ,   28140  )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'lov', 'BE', 1500   ,   3054   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'lov', 'NO', 4000   ,   7026   )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'lov', 'SE', 5000   ,   10201  )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'lov', 'SE', 5000   ,   10201  )
    INSERT INTO month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'lov', 'SE', 5000   ,   10201  )
END
IF (NOT EXISTS(SELECT * FROM dbo.month_targets WHERE month>='2021-01-01'and month<'2022-01-01'and channel='nfn'))  
BEGIN  
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'nfn', 'NL', 2000   ,	28000   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'nfn', 'NO', 450    ,	5500    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'nfn', 'SE', 200    ,	2600    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'nfn', 'GB', 300    ,	5000    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'nfn', 'IE', 10     ,	350     )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'nfn', 'AU', 1300   ,	4350    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-07-01', 'nfn', 'NZ', 250    ,	1285    )

    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'nfn', 'NL', 2000   ,   27529   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'nfn', 'NO', 500    ,   5061    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'nfn', 'SE', 200    ,	2398    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'nfn', 'GB', 350    ,	4584    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'nfn', 'IE', 0      ,	341     )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'nfn', 'AU', 2000   ,	5503    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-08-01', 'nfn', 'NZ', 450    ,	1599    )

    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'nfn', 'NL', 2400   ,	 28333  )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'nfn', 'NO', 550    ,	 5057   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'nfn', 'SE', 200    ,	 2249   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'nfn', 'GB', 500    ,	 4564   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'nfn', 'IE', 0      ,	 348    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'nfn', 'AU', 2000   ,	 6840   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-09-01', 'nfn', 'NZ', 1350   ,	 2465   )

    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'nfn', 'NL', 3000   ,	 28200  )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'nfn', 'NO', 1000   ,	 4967   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'nfn', 'SE', 150    ,	 2060   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'nfn', 'GB', 750    ,	 4262   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'nfn', 'IE', 0      ,	 302    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'nfn', 'AU', 2500   ,	 7365   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-10-01', 'nfn', 'NZ', 1000   ,	 2900   )

    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'nfn', 'NL', 4500   ,	 27075  )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'nfn', 'NO', 1400   ,	 5225   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'nfn', 'SE', 150    ,	 1914   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'nfn', 'GB', 750    ,	 4257   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'nfn', 'IE', 0      ,	 261    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'nfn', 'AU', 3000   ,	 7602   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-11-01', 'nfn', 'NZ', 850    ,	 2765   )

    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'nfn', 'NL', 4250   ,	 28429  )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'nfn', 'NO', 1750   ,	 5690   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'nfn', 'SE', 150    ,	 1757   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'nfn', 'GB', 750    ,	 4148   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'nfn', 'IE', 0      ,	 227    )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'nfn', 'AU', 3500   ,	 8767   )
    INSERT INTO dbo.month_targets (month, channel, country, nr_trials, nr_paid_Customers) VALUES ('2021-12-01', 'nfn', 'NZ', 1000   ,	 2899   )
END
GO
