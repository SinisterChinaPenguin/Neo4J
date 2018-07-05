-- CREATE CONSTRAINT ON (n:Container) ASSERT n.objid IS UNIQUE;


ALTER VIEW neo4jCIs
AS

--SELECT 0 as sortOrder,[ObjID], [ParentObjID],'MERGE(`' + CAST(ObjID AS varchar(10)) + '`:`' + TypeName + '` {props})' as CreateCode, 
SELECT 0 as sortOrder,[ObjID], [ParentObjID],'MERGE(`' + CAST(ObjID AS varchar(10)) + '`:`' + TypeName + '` {
"Name":"' + Name + '",
"Type":"' + TypeName + '",
"Status":"' + s.StatusName + '",
"Scope":"' + scope + '",
"ManagementIP":"' + ISNULL(ManagementIP,'') + '",
"objid":' + CAST(objID AS varchar(10)) + ',
"Class":"' + ISNULL(ClassName,CAST(ObjectClass AS varchar(50))) + '"})' as CreateCode
--as PropsCypher --  ,*
FROM cmdbItems i (NOLOCK)
JOIN sqryStatuses s (NOLOCK)
ON i.Status = s.Status
where (RootDevice=1 OR TypeID=14) -- inclucde containers
AND Deleted_Flag=0
AND i.Status <=3
AND i.TypeName NOT IN ('asset','laptop','rack')

SELECT ObjID INTO #Temp
FROM cmdbItems i (NOLOCK)
JOIN sqryStatuses s (NOLOCK)
ON i.Status = s.Status
where (RootDevice=1 OR TypeID=14) -- inclucde containers
AND Deleted_Flag=0
AND i.Status <=3
AND i.TypeName NOT IN ('asset','laptop')



SELECT 'CREATE(`' + CAST(parentObjID AS varchar(10)) + '`)-[PARENT_OF]->(`' + CAST(ObjID AS varchar(10)) + '`  {props})' AS CreateCode,
'"Weight":1"' as PropsCypher
FROM cmdbItems i (NOLOCK)
where ObjID IN(SELECT ObjID FROM #Temp)
AND ParentObjID IN (SELECT ObjID FROM #Temp)

neo4j_AddCI_Rel

ALTER PROC neo4j_AddCI_Rel
AS

CREATE TABLE #NeoCIs(
	[sortOrder] SMALLINT,
	[ObjID] INT NOT NULL,
	[ParentObjID] INT NOT NULL,
	[CreateCode] [varchar](8000) NULL,
	[PropsCypher] [varchar](8000) NULL
) 


-- Add Create Statements for CIs
INSERT #NeoCIs
SELECT TOP 10 *
FROM neo4jCIs

-- make sure parentCI's are created too (test only)
INSERT #NeoCIs
SELECT TOP 10 *
FROM neo4jCIs
where ObjID IN(SELECT ParentObjID FROM #NeoCIs)

-- Add Relationships between CIs & Parent ONLY WHERE Parent is already created above
INSERT #NeoCIs
SELECT DISTINCT 1,0,0,'MATCH (ci) WHERE ci.objid=' + CAST(ObjID AS varchar(10))+ ' MATCH (parent) WHERE parent.objID=' + CAST(parentObjID AS varchar(10)) + ' CREATE(parent)-[:PARENT_OF]->(ci {props})' AS CreateCode,
'"Weight":1' as PropsCypher
FROM #NeoCIs i (NOLOCK)
where ObjID IN(SELECT ObjID FROM #NeoCIs)
AND ParentObjID IN (SELECT ObjID FROM #NeoCIs)

SELECT *
FROM #NeoCIs
where sortOrder=1
ORDER BY sortOrder

