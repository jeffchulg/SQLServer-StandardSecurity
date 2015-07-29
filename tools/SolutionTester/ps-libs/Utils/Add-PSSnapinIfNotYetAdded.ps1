function Add-PSSnapinIfNotYetAdded {
    param (
        [ValidateNotNullOrEmpty()][string]$Name
    )
    
    $oldPreference          = $ErrorActionPreference
    $ErrorActionPreference  = 'Stop'
    
    try {
        if ((Get-PSSnapin | where-object { $_.Name -eq $Name }) -eq $null) {
            Add-PSSnapin $Name -ErrorAction $ErrorActionPreference
        }
        
        return $true
    }
    catch {
        return $false
    }
    Finally {
        $ErrorActionPreference=$oldPreference
    }
}

