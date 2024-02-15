
USE MASTER 
GO 


IF OBJECT_ID('sp_Find_Obj_Text') IS NOT NULL
DROP PROCEDURE DBO.sp_Find_Obj_Text 
GO

--sp_Find_Obj_Text 'ERROR' , 'v, p', 'dbo'
CREATE PROCEDURE dbo.sp_Find_Obj_Text

	@Search			NVARCHAR(255)
	,@Type			NVARCHAR(255) = NULL --CSV String
	,@Schema		SYSNAME = NULL --CSV String


AS

SET NOCOUNT ON

--gets valid types if @type is null
IF @Type IS NULL SELECT @Type = STRING_AGG(TYPE, ', ') 
	FROM	(SELECT DISTINCT TYPE FROM SYS.Objects O JOIN SYS.sql_modules M ON M.object_id = O.object_id JOIN SYS.schemas S ON O.schema_id = S.schema_id  WHERE s.name LIKE ISNULL(@Schema, '%')) D1

SELECT	O.type
		,O.TYPE_Desc
		,s.name [Schema]
		,o.name
		,s.name + '.' + o.name Q_Name
FROM	SYS.sql_modules M
		JOIN
		SYS.objects O
			ON	M.object_id = O.object_id
		JOIN
		SYS.schemas S
			ON	O.schema_id = S.schema_id
WHERE	O.TYPE IN (SELECT ltrim(rtrim(value)) FROM string_split(@Type, ',') ObjTypes)
AND		M.definition LIKE '%' + @Search + '%'
AND		S.name IN (SELECT ltrim(rtrim(value)) FROM string_split(@Schema, ',') Schemas)
ORDER BY 1, 5
;
GO

EXEC sp_ms_marksystemobject 'sp_Find_Obj_Text' 
GO 

SELECT NAME, IS_MS_SHIPPED 
FROM SYS.OBJECTS 
WHERE NAME = 'sp_Find_Obj_Text' 
GO 
