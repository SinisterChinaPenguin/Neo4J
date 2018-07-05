function Get-Dataset {
    $targetServer="."
	$localMachine=gc env:computername
	$connectionString = "Provider=sqloledb;Data Source=$targetServer;Initial Catalog=CMDB;Trusted_Connection=yes;"
	$connection = New-Object System.Data.OleDb.OleDbConnection $connectionString
#	$command = New-Object System.Data.OleDb.OleDbCommand "EXEC neo4j_AddCI_Rel",$connection
    $command = New-Object System.Data.OleDb.OleDbCommand "EXEC Neo4J_CMDB_Rel",$connection
	$connection.Open()
	$connState=$connection.State
	Write-host "Connection State $connState"
	if($connState -ne "Open") {
		Write-host "bugger - not connected"
	} else {
		Write-host "connected to $targetServer from $localMachine"
	}

	## Fetch the results, and close the connection
	$adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
	$dataset = New-Object System.Data.DataSet
	[void] $adapter.Fill($dataSet)
	$connection.Close()

	Write-Output $dataSet
}

####################### INITIALISE NEO4J CONNECTION ######################

# Neo4J HTTP Endpoint
$serverURL="http://localhost:7474/db/data/transaction/commit"

# Credential Values
$ID="neo4j"
$pw="nightmare"

# Store Password in Psh Credential Object
$secPasswd = ConvertTo-SecureString $pw -AsPlainText -Force
$neo4jCreds = New-Object System.Management.Automation.PSCredential ('neo4j', $secPasswd)  

############################################################################

$neoDS=Get-Dataset
#$neoDS.Tables | Select-Object -Expand Rows

$query='{"statements" : [ '

$i=0


#$query=@"
#{"statements" : [ {
#			"statement" : "MERGE (n:test {Name:'Mike'})"
#			} ]
#		}
#"@	

foreach($row in $neoDS.Tables.rows) {
	$create=$row.CreateCode
#	$props=$row.PropsCypher
	If ($i -eq 0) {
#		$query += "{""statement"" : ""$create"",""parameters"" : {""props"" : {$props}}}"
        $query += "{""statement"" : ""$create""}"
		}Else{
#		$query += ",{""statement"" : ""$create"" ,""parameters"" : {""props"" : {$props}}}"
        $query += ",{""statement"" : ""$create"" }"
	}
	$i+=1
}

 $query+=' ] }'	

#Write-Host $query

$query | Out-File .\query.txt

#exit

# Call Neo4J HTTP EndPoint, Pass in creds & POST JSON Payload
$response = Invoke-WebRequest -Uri $ServerURL -Method POST -Body $query -credential $neo4jcreds -ContentType "application/json"

# Display Full response
$response
# Check Out Content of returned object
$response.Content
	
    
