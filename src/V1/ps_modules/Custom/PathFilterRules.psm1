Function Get-PathFilterChanges {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][System.Object]$BranchCompare,
    [Parameter(Mandatory = $true)][string[]]$PathFilters
  )
  Process {
    $changes = @()

    foreach ($filter in $PathFilters | Where-Object { $_.StartsWith("+") }) {
      $filter = $filter.Replace("+", "")
      if (!$filter.EndsWith("*")) {
        $filter = $filter + "*"
      }
      Write-Verbose "Filtering for path inclusion: [$filter]"
      $changes += ($BranchCompare.changes | Where-Object { $_.item.path -like $filter } | Select-Object -ExpandProperty item) 
    }

    $exclusions = @()
    foreach ($filter in $PathFilters | Where-Object { $_.StartsWith("-") }) {
      $filter = $filter.Replace("-", "")
      Write-Verbose "Filtering for path exclution: [$filter]"
      $exclusions += ($changes | Where-Object { $_.path -like $filter })
    }

    $result = $changes | Where-Object { $exclusions -notcontains $_ }
    return $result
  }
}