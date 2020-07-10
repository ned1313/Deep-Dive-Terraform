#List of plugins
$plugins = @("terraform-provider-aws","terraform-provider-external","terraform-provider-template","terraform-provider-terraform")
#Folder for plugins
$folderpath = ".\terraform_plugins"
#Set to TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Create directory if missing
if(-not (Test-Path $folderpath)){
    New-Item -Path $folderpath -ItemType Directory
}

#This assumes that the first entry in the list is the most recent plugin
foreach($plugin in $plugins){
    #get the main plugin directory
    $resp = Invoke-WebRequest -Uri "https://releases.hashicorp.com/$plugin/"
    #Find the latest version of the plugin
    $versions = $resp.ParsedHtml.getElementsByTagName("li")
    $versionPath = $versions[1].getElementsByTagName("a") | select pathname
    $fileName = [string] $versions[1].innerText.Trim() + "_linux_amd64.zip"
    $downloadPath = [string] $versionPath.pathname + $fileName
    #Download the plugin for Linux
    Invoke-WebRequest -Uri "https://releases.hashicorp.com/$downloadPath" -OutFile "$folderpath\$fileName"
}

$pluginFiles = Get-ChildItem -Path $folderpath
foreach($pluginFile in $pluginFiles){
    Expand-Archive -Path $pluginFile.FullName -DestinationPath $pluginFile.Directory
    Remove-Item $pluginFile.FullName
}