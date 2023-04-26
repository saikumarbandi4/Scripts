$connectionToken="$(pat)"
$base64AuthInfo= [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($connectionToken)"))
$URL = "https://dev.azure.com/{Org name}/{Project name}/_apis/distributedtask/variablegroups?groupIds={Variable group ID}&api-version=6.0-preview.2"
$Result = Invoke-RestMethod -Uri $URL -Headers @{authorization = "Basic $base64AuthInfo"} -Method Get 
 

$Variable = $Result.value.variables | ConvertTo-Json -Depth 100

Write-Host $Variable
