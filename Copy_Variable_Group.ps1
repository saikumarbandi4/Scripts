param ($srcproj,$grpname,$dstproj, $PAT)

#$AllProtocols = [System.Net.SecurityProtocolType]'Tls12'
#[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

$variablegroups_url = "https://dev.azure.com/vgroupframework/$($srcproj)/_apis/distributedtask/variablegroups?groupName=$($grpname)&api-version=5.1-preview.1"

$vargroups = Invoke-RestMethod -Uri $variablegroups_url -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo)} -Method 'GET'

$groupresult = $vargroups | ConvertTo-Json

$jsonid = $groupresult | ConvertFrom-Json

#Write-Host $groupresult

#Write-Host $jsonid

$id = $jsonid.value[0].id #first matching record id

#Get the variable group in projectA

$url = "https://dev.azure.com/vgroupframework/$($srcproj)/_apis/distributedtask/variablegroups/$($id)?api-version=5.1-preview.1"

$result = Invoke-RestMethod -Uri $url -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo)} -Method get -ContentType "application/json"

# check if variable group already exists
$dest_variablegroups_url = "https://dev.azure.com/vgroupframework/$($dstproj)/_apis/distributedtask/variablegroups?groupName=$($grpname)&api-version=5.1-preview.1"

$dest_vargroups = Invoke-RestMethod -Uri $dest_variablegroups_url -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo)} -Method 'GET'

$dest_groupresult = $dest_vargroups | ConvertTo-Json

$dest_jsonid = $dest_groupresult | ConvertFrom-Json

$updateurl = ""
$method = ""
$dest_grpId =[int]$dest_jsonid.value[0].id

#Write-Host $dest_grpId

if($dest_grpId -gt 0)
{
    $updateurl = "https://dev.azure.com/vgroupframework/$($dstproj)/_apis/distributedtask/variablegroups/$($dest_grpId)?api-version=5.1-preview.1"
    $method = "PUT"
}
else
{
    # Call add variable group rest api to add variable group in ProjectB
    $updateurl = "https://dev.azure.com/vgroupframework/$($dstproj)/_apis/distributedtask/variablegroups?api-version=5.1-preview.1"
    $method = "POST"
}

$body = $result | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri $updateurl -Headers @{Authorization = "Basic {0}" -f $base64AuthInfo} -ContentType "application/json" -Method $method -Body $body
