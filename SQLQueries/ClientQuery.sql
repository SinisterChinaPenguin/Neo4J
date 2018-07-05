

-- Add clients
SELECT 'MERGE (`'+ name +'`:`' + TypeName + '` {Name:"' + Name + '",Status:"' + s.statusName + '",Description:"' + ISNULL(description,'') + '", ThreeLetterCode:"' + ISNULL(Attribute3,'') + '", Scope:"' + scope + 
'", ClassName:"' + ClassName + '", deleted_flag:"' + CASE WHEN deleted_flag=-1 THEN '1' ELSE CAST(deleted_flag AS CHAR(1)) END + '", OwnedBy:"' + ISNULL(ownedBy,'Unknown') + '"})'
FROM CMDBItems i
JOIN [dbo].[sqryStatuses] s
ON i.status = s.Status
WHERE TypeID=15
--AND parentObjName='Attenda Groups'--'clients'
AND name LIKE 'reg%'
order by name

-- Add Servers
SELECT 'MERGE (`'+ name +'`:`' + TypeName + '` {Name:"' + Name + '", deleted_flag:"' + CASE WHEN deleted_flag=-1 THEN '1' ELSE CAST(deleted_flag AS CHAR(1)) END 
+ '",Status:"' + s.statusName + '",Description:"' + ISNULL(REPLACE(description,'\',' '),'')
 + '",`' + Header1 + '`:"' + ISNULL(Attribute1,'')
 + '",`' + Header2 + '`:"' + ISNULL(Attribute2,'')
 + '",`' + Header3 + '`:"' + ISNULL(Attribute3,'')
 + '",`' + Header4 + '`:"' + ISNULL(Attribute4,'')
 + '",`' + Header5 + '`:"' + ISNULL(Attribute5,'')
 + '",`' + Header6 + '`:"' + ISNULL(Attribute6,'')
 + '",`' + Header7 + '`:"' + ISNULL(REPLACE(Attribute7,'\',' '),'')
 + '",Scope:"' + scope
 + '",ClassName:"' + ClassName + '",OwnedBy:"' + ISNULL(ownedBy,'Unknown') + '"})' as Cypher


CREATE VIEW Neo4j.CMDBServers
AS



SELECT '"MERGE (ci:`Windows Server` {Name:{p_server}, deleted_flag:{p_deleted},Status:{p_status},Description:{p_description},`OS Version`:{p_osversion},`Service Pack`:{p_servicepack},`Processor #`:{p_proc},`CPU Speed (MHz)`:{p_cpuspeed},`Memory`:{p_memory},`Architecture`:{p_arch},`Domain (role)`:{p_domrole},Scope:{p_scope},ClassName:{p_class},OwnedBy:{p_ownedby} })"
,"params" : { "p_server" : "' + name + '"
, "p_deleted" : "' + CASE WHEN deleted_flag=-1 THEN '1' ELSE CAST(deleted_flag AS CHAR(1)) END + '"
, "p_status" : "' + s.statusName + '"
, "p_description" : "' + ISNULL(REPLACE(description,'\',' '),'') + '"
, "p_osversion" : "' + ISNULL(Attribute1,'') + '"
, "p_servicepack" : "' + ISNULL(Attribute2,'') + '"
, "p_proc" : "' + ISNULL(Attribute3,'') + '"
, "p_cpuspeed" : "' + ISNULL(Attribute4,'') + '"
, "p_memory" : "' + ISNULL(Attribute5,'') + '"
, "p_arch" : "' + ISNULL(Attribute6,'') + '"
, "p_domrole" : "' + ISNULL(REPLACE(Attribute7,'\',' '),'') + '"
, "p_scope" : "' + scope + '"
, "p_class" : "' + classname + '"
, "p_ownedby" : "' + ISNULL(ownedBy,'Unknown') + '"} }'
,client,name
FROM CMDB..CMDBItemswithClient i (NOLOCK)
JOIN CMDB.[dbo].[sqryStatuses] s  (NOLOCK)
ON i.status = s.Status
WHERE ObjectClass=1
AND Deleted_flag=0
AND Name is not null
AND header1 IS NOT NULL
AND header2 IS NOT NULL
AND header3 IS NOT NULL
AND header4 IS NOT NULL
AND header5 IS NOT NULL
AND header6 IS NOT NULL
AND header7 IS NOT NULL

SELECT cypher,client,name FROM Neo4j.CMDBServers WHERE Client LIKE 'Regus%'


-- add server -> client relationship
MATCH (client:Client) WHERE client.Name="Attenda Enterprise Architecture" 
MATCH (ci:`Windows Server`) WHERE ci.Name="ATT10DBS03"
CREATE (client)-[r:OWNS]->(ci)
RETURN client,r,ci


SELECT 'MATCH (client:Client {Name: {client1} }) WHERE client.Name="' + Client + '" MATCH (ci:`' + typename + '`) WHERE ci.Name="' + name + '" MERGE (client)-[r:OWNS]->(ci)'


ALTER VIEW NEO4J.ClientsServers
AS
-- Create Cyper queries to relate Clients to Servers for Graph
--SELECT '""MATCH (client:Client {Name: {client1} }) MATCH (ci:``' + typename + '`` {Name: {server1} }) MERGE (client)-[r:OWNS]->(ci)"",""params"" : { ""client1"" : ""' + Client + '"" , ""server1"" : ""' + name + '""} }' as Cypher
SELECT '"MATCH (client:Client {Name: {client1} }) MATCH (ci:`' + typename + '` {Name: {server1} }) MERGE (client)-[r:OWNS]->(ci)","params" : { "client1" : "' + Client + '" , "server1" : "' + name + '"} }"' as Cypher
FROM CMDB..CMDBItemswithClient i (NOLOCK)
WHERE ObjectClass=1
AND CLient LIKE 'a%'
AND Deleted_flag=0
AND Name is not null
AND header1 IS NOT NULL
AND header2 IS NOT NULL
AND header3 IS NOT NULL
AND header4 IS NOT NULL
AND header5 IS NOT NULL
AND header6 IS NOT NULL
AND header7 IS NOT NULL
AND name NOT IN ('att01sto01','att30sec02','bes02','esxgs2-03','eudc01','fileserver')


CREATE Schema NEO4J



SELECT TOP 100 *
FROM CMDBItems
WHERE ObjectClass=1
AND Deleted_flag=0



SELECT CAST(deleted_flag AS VARCHAR(1)),
deleted_flag=CASE WHEN deleted_flag=-1 THEN '1' ELSE CAST(deleted_flag AS CHAR(1)) END
,* FROM CMDBItems
WHERE TypeID=15
AND parentObjName='clients'
AND name LIKE 'st james%'

AND name <> 'attenda enterprise architecture'
order by name

SELECT 