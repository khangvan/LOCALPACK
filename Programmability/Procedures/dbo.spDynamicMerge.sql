SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/* 
==============================================================================
Author:		    Tommy Swift
Name:           spDynamicMerge
Create date:    5/18/2015
Description:	Stored Procedure to Create MERGE Statements from Source Table
                joining back to target tables on PK columns for CRUD statement
                comparisons
Parameters:     @schemaName - Default = 'dbo' 
				@tableName to be Merged.  
				Schema required if table schema name is other than 'dbo'
Assumptions:    - The parameter table exists on both the Source and Target 
                    and PK's are the same on both DB tables.
                - PK columns will be used to determine record existence.
                - SP resides on the Target database where the filtered list
                    of columns per table occur.  This ensures that only the
                    columns used in the Target are evaluated.
==============================================================================
*/



CREATE PROCEDURE [dbo].[spDynamicMerge]
	@schemaName VARCHAR(100) = 'dbo',
	@tableName VARCHAR(8000)
AS
BEGIN TRANSACTION	
	SET NOCOUNT ON;
	BEGIN TRY
    
    DECLARE  @pkColumnsCompare VARCHAR(8000)            
            ,@nonPKColumnsTarget VARCHAR(8000)
            ,@nonPKColumnsSource VARCHAR(8000)
            ,@nonPKColumnsCompare VARCHAR(8000)
            ,@columnListingSource VARCHAR(8000)
            ,@columnListingTarget VARCHAR(8000)
            ,@sqlCommand NVARCHAR(4000)

    
    --Get list of PK columns for Insert determination
    SELECT @pkColumnsCompare = COALESCE(@pkColumnsCompare + ' AND ', '') + 'Target.' + c.name + ' = ' + 'Source.' + c.name           
	FROM sys.indexes i 
        INNER JOIN sys.index_columns ic 
            ON ic.object_id = i.object_id 
				AND i.index_id = ic.index_id 
        INNER JOIN sys.columns c
            ON ic.object_id = c.object_id
                AND ic.column_id = c.column_id  
        INNER JOIN sys.tables t
            ON t.object_id = c.object_id     
		INNER JOIN sys.schemas s
			on s.schema_id = t.schema_id 
    WHERE i.is_primary_key = 1
		AND s.name + '.' + t.name = @schemaName + '.' + @tableName

    
	--Get List of non-PK columns for Updates
    SELECT @nonPKColumnsTarget = COALESCE(@nonPKColumnsTarget + ', ', '') + 'Target.' + c.name
        ,  @nonPKColumnsSource = COALESCE(@nonPKColumnsSource + ', ', '') + 'Source.' + c.name
        ,  @nonPKColumnsCompare = COALESCE(@nonPKColumnsCompare + ', ', '') + 'Target.' + c.name + ' = ' + 'Source.' + c.name
    FROM 
    (SELECT DISTINCT c.name
    FROM sys.tables t
        INNER JOIN sys.schemas s
			on s.schema_id = t.schema_id
		LEFT JOIN sys.columns c
            ON t.object_id = c.object_id  
        LEFT JOIN sys.indexes i
            ON i.object_id = c.object_id    
        LEFT JOIN sys.index_columns ic 
            ON ic.object_id = i.object_id 
                AND ic.column_id = c.column_id  
    WHERE ic.object_id IS NULL AND
        s.name + '.' + t.name = @schemaName + '.' + @tableName         
    ) c

    
    -- Create comma delimited column listing
    SELECT @columnListingTarget = COALESCE(@columnListingTarget + ', ', '') + c.name
        , @columnListingSource = COALESCE(@columnListingSource + ', ', '') + 'Source.'+ c.name    
    FROM 
    (SELECT DISTINCT c.name
    FROM sys.tables t
		INNER JOIN sys.schemas s
			on s.schema_id = t.schema_id
        INNER JOIN sys.columns c
            ON t.object_id = c.object_id      
    WHERE s.name + '.' + t.name = @schemaName + '.' + @tableName         
    ) c

    --select @pkColumnsCompare, @nonPKColumnsTarget, @nonPKColumnsSource, @nonPKColumnsCompare, @columnListingTarget, @columnListingSource

    SELECT @sqlCommand = 
	'WITH temp AS ' + CHAR(13) + CHAR(10) + 
	'(' + CHAR(13) + CHAR(10) +
	' SELECT * FROM AdventureWorks2012.' + @schemaName + '.' + @tableName + ' WITH(NOLOCK) ' + CHAR(13) + CHAR(10) +		
	') ' + CHAR(13) + CHAR(10) +
	'MERGE DataPatternsStage.' + @schemaName + '.' + @tableName  + ' AS Target ' + CHAR(13) + CHAR(10) +
     'USING temp AS Source ' + CHAR(13) + CHAR(10) +
        'ON ' + @pkColumnsCompare + CHAR(13) + CHAR(10) +
    ' WHEN MATCHED THEN ' + CHAR(13) + CHAR(10) +
       'UPDATE SET ' + @nonPKColumnsCompare + CHAR(13) + CHAR(10) +
    ' WHEN NOT MATCHED BY TARGET ' + CHAR(13) + CHAR(10) +
    'THEN ' + CHAR(13) + CHAR(10) +
       'INSERT (' + @columnListingTarget + ') ' + CHAR(13) + CHAR(10) +
       'VALUES (' + @columnListingSource + '); '

    --select @sqlCommand
    
    EXECUTE sp_executesql @sqlCommand

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 
				   @ErrorSeverity,
				   @ErrorState
				   );

	END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

GO