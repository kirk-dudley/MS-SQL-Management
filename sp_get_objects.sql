
USE MASTER 
GO 

IF OBJECT_ID('SP_Get_Objects') IS NOT NULL
DROP PROCEDURE DBO.SP_Get_Objects
GO

--DROP PROCEDURE SP_Get_Objects 
--ALTER PROCEDURE SP_Get_Objects 
CREATE PROCEDURE DBO.SP_Get_Objects 

	@Type		SYSNAME = NULL
	,@Schema	SYSNAME = NULL
	,@Name		SYSNAME = NULL


AS

SELECT DB_NAME() AS Current_Database
;

SELECT	O.type_desc
		,O.type 
		,S.name Schema_Name
		,o.name Object_Name
		,s.name + '.' + o.name Qualified_Name
FROM	SYS.objects o
		join
		sys.schemas s
			ON	O.schema_id = S.schema_id
WHERE	(O.type LIKE ISNULL(@Type, '%') OR O.type_desc LIKE ISNULL(@Type, '%')) --allows for wildcards, all values if null
AND		S.name LIKE ISNULL(@Schema, '%')
AND		o.name LIKE ISNULL(@Name, '%')
ORDER BY O.type_desc
		,s.name + '.' + o.name
;
GO

EXEC sp_ms_marksystemobject 'SP_Get_Objects' 
GO 

SELECT NAME, IS_MS_SHIPPED 
FROM SYS.OBJECTS 
WHERE NAME = 'SP_Get_Objects' 
GO 