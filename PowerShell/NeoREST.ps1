# Neo4J HTTP Endpoint
$serverURL="http://localhost:7474/db/data/transaction/commit"

# Credential Values
$ID="neo4j"
$pw="nightmare" #"EatNotCheese"

# Store Password in Psh Credential Object
$secPasswd = ConvertTo-SecureString $pw -AsPlainText -Force
$neo4jCreds = New-Object System.Management.Automation.PSCredential ('neo4j', $secPasswd)  


# Cypher query using parameters to pass in properties
$query=@"
{"statements" : [ {
			"statement" : "CREATE (n:test {props}) RETURN n",
			"parameters" : {
			  "props" : {
				"Name":"Mike",
				"Occupation":"LifeCoach"
			  }
			}  
			} ]
		}
"@			

# Call Neo4J HTTP EndPoint, Pass in creds & POST JSON Payload
$response = Invoke-WebRequest -Uri $serverURL -Method POST -Body $query -credential $neo4jCreds -ContentType "application/json"

# Display Full response
$response

