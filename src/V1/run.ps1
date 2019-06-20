[CmdletBinding()]
param(
  [Parameter()][string]$CollectionUri = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI,
  [Parameter()][string]$Project = $env:SYSTEM_TEAMPROJECT,
  [Parameter()][string]$Repository = $env:BUILD_REPOSITORY_NAME,
  [Parameter()][string]$BuildId = $env:BUILD_BUILDID,
  [Parameter()][string]$BuildReason = $env:BUILD_REASON,
  [Parameter()][string]$PAT = $env:SYSTEM_ACCESSTOKEN
)

# Trace-VstsEnteringInvocation $MyInvocation

# $env:TEAM_AuthType = Get-VstsInput -Name "authenticationType" -Require
# $env:TEAM_PAT = $env:SYSTEM_ACCESSTOKEN

# $taskProperties = New-Object psobject -Property @{
#   SourceBranchName = Get-VstsInput -Name "sourceBranchName" -Require
#   NewBranchName    = Get-VstsInput -Name "newBranchName" -Require
# }

Write-Output "Project Collection: [$CollectionUri]"
Write-Output "Project Name: [$Project]"
Write-Output "Build Id: [$($BuildId)]"
Write-Output "Build Reason: [$($BuildReason)]"
Write-Output "Repository: [$Repository]"
# Write-Output "Current Branch: [$($Build.SourceBranch)]"
Write-Output "Authentication Type: [$env:TEAM_AUTHTYPE]"
# Write-Output "Task Inputs:"
# $taskProperties

$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).FullName

#Import Required Modules
Import-Module "$scriptLocation\ps_modules\Custom\team.Extentions.psm1" -Force

Get-BranchDiff -Repository $Repository -BaseBranch master -TargetBranch "feature/kc-demo"

# Trace-VstsLeavingInvocation $MyInvocation