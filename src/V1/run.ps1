[CmdletBinding()]
param(
  [Parameter()][string]$CollectionUri = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI,
  [Parameter()][string]$Project = $env:SYSTEM_TEAMPROJECT,
  [Parameter()][string]$Repository = $env:BUILD_REPOSITORY_NAME,
  [Parameter()][string]$BuildId = $env:BUILD_BUILDID,
  [Parameter()][string]$BuildReason = $env:BUILD_REASON,
  [Parameter()][string]$BuildSourceBranch = $env:BUILD_SOURCEBRANCH,
  [Parameter()][string]$DefinitionId = $env:System_DEFINITIONID

)

Trace-VstsEnteringInvocation $MyInvocation

$env:TEAM_AuthType = Get-VstsInput -Name "authenticationType" -Require
$env:TEAM_PAT = $env:SYSTEM_ACCESSTOKEN

$task = New-Object psobject -Property @{
  SourceBranchName = Get-VstsInput -Name "sourceCompareBranchName" -Require
}

$task.SourceBranchName = $($task.SourceBranchName).Replace("refs/heads/", "")
$BuildSourceBranch = $BuildSourceBranch.Replace("refs/heads/", "")

Write-Output "Project Collection: [$CollectionUri]"
Write-Output "Project Name: [$Project]"
Write-Output "Build Definition Id: [$DefinitionId]"
Write-Output "Build Id: [$($BuildId)]"
Write-Output "Build Reason: [$($BuildReason)]"
Write-Output "Repository: [$Repository]"
Write-Output "Current Branch: [$($BuildSourceBranch)]"
Write-Output "Authentication Type: [$env:TEAM_AUTHTYPE]"
Write-Output "Task Inputs:"
$task

$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).FullName

#Import Required Modules
Import-Module "$scriptLocation\ps_modules\Custom\team.Extentions.psm1" -Force

$buildDefinition = Get-BuildDefinition -DefinitionId $DefinitionId
$buildDefinition | Format-List

$branchDiff = Get-BranchDiff -Repository $Repository -BaseBranch $task.SourceBranchName -TargetBranch $BuildSourceBranch

if ($branchDiffResult -and $branchDiffResult.length -gt 0) { 
  Write-Output "------------------------------------------------------------------------------"
  Write-Output "Changes:"
  Write-Output "------------------------------------------------------------------------------"
  $branchDiffResult | Select-Object * | Format-Table -Wrap
  Write-Output "------------------------------------------------------------------------------"
  Write-Output "Passed the path filter gate..."
}
else {
  Write-Error "There were no changes. Failed branch filter"
}

Trace-VstsLeavingInvocation $MyInvocation