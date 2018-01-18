# Read stdin as string
$jsonpayload = [Console]::In.ReadLine()

# Convert to JSON
$json = ConvertFrom-Json $jsonpayload

# Access JSON values 
$workspace = $json.workspace
$projectcode = $json.projectcode
$url = $json.url

#Configure the query
$headers = @{}
$headers.Add("querytext","$workspace-$projectcode")
$response = Invoke-WebRequest -uri $url -Method Get -Headers $headers

#Return response to stdout
Write-Output $response.content