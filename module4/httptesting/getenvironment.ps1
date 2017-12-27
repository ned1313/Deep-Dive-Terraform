# Read stdin as string
$jsonpayload = [Console]::In.ReadLine()

# Convert to JSON
$json = ConvertFrom-Json $jsonpayload

# Access JSON values 
$workspace = $json.workspace
$projectcode = $json.projectcode
$url = $json.url

Add-Content -Path ".\getenvironment.txt" -Value "Workspace $workspace"
Add-Content -Path ".\getenvironment.txt" -Value "Project Code $projectcode"
Add-Content -Path ".\getenvironment.txt" -Value "URL $url"
#Configure the query
$headers = @{}
$headers.Add("QueryText","$workspace-$projectcode")
$response = Invoke-WebRequest -uri $url -Method Get -Headers $headers
$output = $response.content -replace "[\[\]]",""

Add-Content -Path ".\getenvironment.txt" -Value $output
#Return response to stdout
Write-Output $output