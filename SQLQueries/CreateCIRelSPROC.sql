USE [CMDB]
GO
/****** Object:  StoredProcedure [dbo].[neo4j_Add_Rel]    Script Date: 03/07/2018 19:18:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[neo4j_Add_Rel]
AS

CREATE TABLE #NeoCIs(
	[sortOrder] SMALLINT,
	[ObjID] INT NOT NULL,
	[ParentObjID] INT NOT NULL,
	[CreateCode] [varchar](8000) NULL,
	RootObjID INT
) 

-- Add Create Statements for CIs
INSERT #NeoCIs
SELECT *
FROM neo4jCIs

-- Bypass non root parents (mainly containers) & relate to root object instead
UPDATE #NeoCIs
SET ParentObjID=RootObjID
FROM #NeoCIs
WHERE #NeoCIs.ParentObjID NOT IN (SELECT objid FROM #NeoCIs)

-- make sure parentCI's are created too (test only)
--INSERT #NeoCIs
--SELECT *
--FROM neo4jCIs
--where ObjID IN(SELECT ParentObjID FROM #NeoCIs)

-- Add Relationships between CIs & Parent ONLY WHERE Parent is already created above
INSERT #NeoCIs
SELECT DISTINCT 1,0,0,'MATCH (ci) WHERE ci.objid=' + CAST(ObjID AS varchar(10))+ ' MATCH (parent) WHERE parent.objid=' + CAST(parentObjID AS varchar(10)) + ' MERGE(parent)-[:PARENT_OF{"Weight":1}]->(ci)' AS CreateCode,0
FROM #NeoCIs i (NOLOCK)
--where ObjID IN(SELECT ObjID FROM #NeoCIs)
--AND ParentObjID IN (SELECT ObjID FROM #NeoCIs)

SELECT *
FROM #NeoCIs
where sortOrder=1
ORDER BY sortOrder
