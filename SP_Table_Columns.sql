
USE MASTER 
GO 


IF OBJECT_ID('SP_Table_Columns') IS NOT NULL
DROP PROCEDURE DBO.SP_Table_Columns
GO

--SP_Table_Columns 'spt_fallback_db'
CREATE PROCEDURE dbo.SP_Table_Columns

	@Obj_Name		SYSNAME
	,@Schema		SYSNAME = NULL
	,@Prefix		NVARCHAR(255) = NULL
	,@Postfix		NVARCHAR(255) = NULL
	,@Tabs			INT = 1

AS

SET NOCOUNT ON

IF NOT EXISTS
	(
	SELECT	*
	FROM	SYS.objects O
			JOIN
			SYS.schemas S
				ON	O.schema_id = S.schema_id
	WHERE	O.type IN ('U', 'V', 'S')			--ONLY OBJECTS WITH COLUMNBS
	AND		O.name = @Obj_Name
	AND		S.name LIKE ISNULL(@Schema, '%')	--All schemas if left blank
	)
BEGIN
	SELECT @Obj_Name = 'The object ' + ISNULL(@Schema + '.', '') + @Obj_Name + ' does not exist'; --NULL @Schema will take the "." with it in the isnull
	THROW 50000, @Obj_Name, 1;
	RETURN 1
END

DECLARE @@Results TABLE (Name NVARCHAR(512), column_id	INT);


INSERT INTO @@Results 
SELECT	'(', 0

	UNION

SELECT	C.name
		,C.column_id
FROM	SYS.objects O
		JOIN
		SYS.Columns C
			ON	O.object_id = C.object_id
		JOIN
		SYS.schemas S
			ON	O.schema_id = S.schema_id
WHERE	O.type IN ('U', 'V', 'S')			--ONLY OBJECTS WITH COLUMNBS
AND		O.name = @Obj_Name
AND		S.name LIKE ISNULL(@Schema, '%')	--All schemas if left blank
ORDER BY 2

INSERT INTO @@Results 
SELECT	')', (SELECT MAX(column_id) + 1 FROM @@Results)

IF @Prefix IS NOT NULL
BEGIN
	UPDATE @@Results SET Name = @Prefix + NAME WHERE Name NOT IN ('(', ')')
END
ELSE
BEGIN
	UPDATE @@Results SET Name = ',' + NAME WHERE Name NOT IN ('(', ')') AND column_id > 1
END;


UPDATE @@Results
SET		Name = Name + ISNULL(@PostFix, '')
WHERE	NAME NOT IN ('(', ')');


SELECT REPLICATE(CHAR(9), @Tabs) + Name
FROM @@Results;



EXEC sp_ms_marksystemobject 'SP_Table_Columns' 
GO 

SELECT NAME, IS_MS_SHIPPED 
FROM SYS.OBJECTS 
WHERE NAME = 'SP_Table_Columns' 
GO 