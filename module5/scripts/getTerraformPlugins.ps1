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

foreach($plugin in $plugins){
    #get the main plugin directory
    $resp = Invoke-WebRequest -Uri "https://releases.hashicorp.com/$plugin/"
    #Find the latest version of the plugin
    $version = $resp.ParsedHtml.getElementsByTagName("li") | Sort-Object -Property innerText -Descending | select -First 1
    $versionPath = $version.getElementsByTagName("a") | select pathname
    $fileName = [string] $version.innerText.Trim() + "_linux_amd64.zip"
    $downloadPath = [string] $versionPath.pathname + $fileName
    #Download the plugin for Linux
    Invoke-WebRequest -Uri "https://releases.hashicorp.com/$downloadPath" -OutFile "$folderpath\$fileName"
}

$pluginFiles = Get-ChildItem -Path $folderpath
foreach($pluginFile in $pluginFiles){
    Expand-Archive -Path $pluginFile.FullName -DestinationPath $pluginFile.Directory
    Remove-Item $pluginFile.FullName
}