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
Write-Output "Source Compare Branch: [$($task.SourceBranchName)]"

$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).FullName

#Import Required Modules
Import-Module "$scriptLocation\ps_modules\Custom\PathFilterRules.psm1" -Force
Import-Module "$scriptLocation\ps_modules\Custom\team.Extentions.psm1" -Force

$definition = Get-BuildDefinition -DefinitionId $DefinitionId
$pathFilters = Get-BuildDefinitionPathFilters -Definition $definition

Write-Output "Build Definition Path Filters:"
$pathFilters | Format-Table -Wrap

$branchCompare = Get-BranchDiff -Repository $Repository -BaseBranch $task.SourceBranchName -TargetBranch $BuildSourceBranch
[bool]$result = $false

Write-Output "Changes:"
Write-Output "------------------------------------------------------------------------------"
$branchCompare.changes | Select-Object -ExpandProperty item | Select-Object path | Format-Table -Wrap

if ($branchCompare -and $branchCompare.changes.Count -gt 0 -and $pathFilters.length -gt 0) { 
  Write-Output "Changes after path filters applied:"
  Write-Output "------------------------------------------------------------------------------"  
  [object[]]$pathChanges = Get-PathFilterChanges -BranchCompare $branchCompare -PathFilters $pathFilters
  $pathChanges | Select-Object path | Format-Table -Wrap

  if ($pathChanges -and $pathChanges.Length -gt 0) { 
    $result = $true
  }
}

if ($pathFilters.length -gt 0 -and $result -eq $true) { 
  Write-Output "Passed the path filter gate..."
}
else { 
  Write-Error "There were no changes. Failed branch filter"
}

Trace-VstsLeavingInvocation $MyInvocation