$sut = 'PathFilterRules'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$assetsPath = Join-Path $here 'assets'
$sourcePath = Join-Path (Get-Item -Path $here).Parent.FullName "src\V1"
$modulesPath = Join-Path $sourcePath "ps_modules\Custom"

Write-Host " Importing module from $modulesPath\$sut.psm1"
Import-Module "$modulesPath\$sut.psm1" -Force -DisableNameChecking
Import-Module "$modulesPath\team.Extentions.psm1" -Force -DisableNameChecking

Describe "PathFilterRules Module Tests" {


  Context "Generic Tests" { 
    It "has a $sut.psm1 file" {
      "$modulesPath\$sut.psm1" | Should Exist
    }

    It "$sut is valid PowerShell code" {
      $psFile = Get-Content -Path "$modulesPath\$sut.psm1" -ErrorAction Stop
      $errors = $null;
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should Be 0
    }
  }

  Context "Branch Compare with no differences" {

    $branchCompare = Get-Content "$assetsPath\BranchCompare.NoDifferences.json" | Out-String | ConvertFrom-Json
    $Definition = Get-Content "$assetsPath\Definition.WithPathFilters.json" | Out-String | ConvertFrom-Json
    $pathFilters = $Definition.triggers[0].pathFilters

    $result = Get-PathFilterChanges -BranchCompare $branchCompare -PathFilters $pathFilters

    It "Should return 0 - no differences" {
      $result.Count | Should Be 0
    }
  }

  Context "Branch Compare with file differences" {

    $branchCompare = Get-Content "$assetsPath\BranchCompare.WithDifferences.V2.json" | Out-String | ConvertFrom-Json
    $Definition = Get-Content "$assetsPath\Definition.WithPathFilters.json" | Out-String | ConvertFrom-Json
    [String[]]$pathFilters = @("-/docs")

    [object[]]$result = Get-PathFilterChanges -BranchCompare $branchCompare -PathFilters $pathFilters

    It "Should return 2 differences" {
      $result.Length | Should Be 1
    }
  }

}
