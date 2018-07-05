USE [CMDB]
GO

/****** Object:  View [dbo].[neo4jCIs]    Script Date: 03/07/2018 19:17:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[neo4jCIs]
AS

--SELECT 0 as sortOrder,[ObjID], [ParentObjID],'MERGE(`' + CAST(ObjID AS varchar(10)) + '`:`' + TypeName + '` {props})' as CreateCode, 
SELECT 0 as sortOrder,[ObjID], [ParentObjID],
'MERGE(`' + CAST(ObjID AS varchar(10)) + '`:`' + TypeName + '` {Name:''' + [dbo].[neo4JEscape](Name) + ''' ,Type:''' + [dbo].[neo4JEscape](TypeName) + ''',Status:''' + [dbo].[neo4JEscape](s.StatusName) + ''',Scope:''' + [dbo].[neo4JEscape](scope) + ''',ManagementIP:''' + [dbo].[neo4JEscape](ISNULL(ManagementIP,'')) + ''',objid:' + [dbo].[neo4JEscape](CAST(objID AS varchar(10))) + ',Class:''' + [dbo].[neo4JEscape](ISNULL(ClassName,CAST(ObjectClass AS varchar(50)))) + '''})' as CreateCode
,RootObjID
FROM cmdbItems i (NOLOCK)
JOIN sqryStatuses s (NOLOCK)
ON i.Status = s.Status
where RootDevice=1
--where (RootDevice=1 OR TypeID=14) -- inclucde containers
AND Deleted_Flag=0
AND i.Status <=3
AND i.TypeName NOT IN ('asset','laptop','rack')
AND i.ClassName NOT IN ('Desktop Equipment')




GO


