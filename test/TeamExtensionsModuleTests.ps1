$sut = 'team.Extentions.psm1'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$assetsPath = Join-Path $here 'assets'
$sourcePath = Join-Path (Get-Item -Path $here).Parent.FullName "src\V1"
$modulesPath = Join-Path $sourcePath "ps_modules\Custom"

Write-Host " Importing module from $modulesPath\$sut"
Import-Module "$modulesPath\$sut" -Force -DisableNameChecking

Describe "Team Extensions Module Tests" {

  Context "Generic Tests" { 
    It "has a $sut.psm1 file" {
      "$modulesPath\$sut" | Should Exist
    }

    It "$sut is valid PowerShell code" {
      $psFile = Get-Content -Path "$modulesPath\$sut" -ErrorAction Stop
      $errors = $null;
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should Be 0
    }
  }

  Context "Get-BuildDefinitionPathFilters With Path Filters Tests" {

    $Definition = Get-Content "$assetsPath\Definition.WithPathFilters.json" | Out-String | ConvertFrom-Json

    It "Should return 2 path filters" {

      $Definition = Get-Content "$assetsPath\Definition.WithPathFilters.json" | Out-String | ConvertFrom-Json
      $result = Get-BuildDefinitionPathFilters -Definition $Definition

      $result.Count | Should Be 2
      $result[0] | Should Be "+/Database"
      $result[1] | Should Be "-/Database.App1/src/App1*"
    }
  }

  Context "Get-BuildDefinitionPathFilters Without Path Filters Tests" {

    $Definition = Get-Content "$assetsPath\Definition.WithPathFilters.json" | Out-String | ConvertFrom-Json

    It "Should return 0 path filters" {

      $Definition = Get-Content "$assetsPath\Definition.WithoutPathFilters.json" | Out-String | ConvertFrom-Json
      $result = Get-BuildDefinitionPathFilters -Definition $Definition

      $result.Count | Should Be 0
    }
  }

}
