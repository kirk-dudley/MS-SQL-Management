--DROP PROCEDURE SP_Find_Table_By_Col
CREATE PROCEDURE SP_Find_Table_By_Col

	@Column		SYSNAME

AS

SELECT	DISTINCT 
		SO.type AS Object_Type
		,SS.name AS Schema_Name
		,SO.name AS Object_Name
		,SS.name + '.' + SO.name AS Qualified_Name
FROM	SYS.objects SO
		JOIN
		SYS.columns SC
			ON	SO.object_id = SC.object_id
		JOIN
		SYS.schemas SS
			ON	SO.schema_id = SS.schema_id
WHERE	SC.name = @Column
ORDER BY SO.name

/*
EXEC sys.sp_MS_marksystemobject SP_Find_Table_By_Col
GO
*/