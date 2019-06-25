#Install-Module -Name newtonsoft.json
#Install tfx-cli using npm
#npm install -g tfx-cli
$ErrorActionPreference = "Stop"

$rootPath = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
# $scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).FullName
$distPath = Join-Path $rootPath "dist"
$srcPath = Join-Path $rootPath "src"

New-Item -Path $distPath -ItemType Directory -Force
Remove-Item -Path "$distPath\*" -Filter *.vsix

$taskFilePath = Join-Path $srcPath "V1\task.json"
$vssExtensionFilePath = Join-Path $srcPath "vss-extension.json"

$task = Get-Content -Path $taskFilePath -raw | ConvertFrom-JsonNewtonsoft
$currentVersion = "$($task.version.Major).$($task.version.Minor).$($task.version.Patch)"
$task.version.Patch = "$([System.Convert]::ToInt32($task.version.Patch) + 1)"
[string]$newVersionNumber = "$($task.version.Major).$($task.version.Minor).$($task.version.Patch)"
$task | ConvertTo-JsonNewtonsoft | set-content $taskFilePath

Write-Host "Updating Task: $($task.name)" -ForegroundColor Yellow
Write-Host "Current Version: $currentVersion"
Write-Host "New Version: $newVersionNumber"

$extensionJson = Get-Content -Path $vssExtensionFilePath -raw | ConvertFrom-JsonNewtonsoft
$currentExtensionVersion = $extensionJson.version
$extensionJson.version = "$newVersionNumber"
$extensionJson | ConvertTo-JsonNewtonsoft | set-content $vssExtensionFilePath

Write-Host "Updated VSS-Extension: $($extensionJson.name)" -ForegroundColor Yellow
Write-Host "Current Version: $($currentExtensionVersion)"
Write-Host "New Version: $newVersionNumber"

# tfx login --service-url "http://devads/DefaultCollection" --authType pat --token "dk26fcbmrkf6nq4tkiedm3fopdegscheeb257ufoc7uzrwp67yra"
# tfx login --service-url "http://devads/DefaultCollection" --authType pat --token "2vdfrhez7iyjy64yrep7eldqcqlijh5f6z23o5pvv4yj3x7g6imq"
tfx login --service-url "http://azuredevops/BingoCollection" --authType pat --token "qcgcrwrskldtxygrke57hwzcuyx77zqoagouudn53hwoupa2auuq"

Write-Host $vssExtensionFilePath
Write-Host $distPath

$currentLocation = Get-Location
Set-Location $srcPath
tfx extension create --manifest $vssExtensionFilePath --output-path $distPath
tfx build tasks upload --task-path $(Join-Path $srcPath "V1")
Set-Location $currentLocation
