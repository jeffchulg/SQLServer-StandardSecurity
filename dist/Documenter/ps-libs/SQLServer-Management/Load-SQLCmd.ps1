function Load-SQLCmd {
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

    Function Test-PSCommandExists {
        Param ($command)
        
        $oldPreference          = $ErrorActionPreference
        $ErrorActionPreference  = 'stop'
        try {
            if(Get-Command $command){
                RETURN $true
            }
        }
        Catch {
            #Write-Verbose "$command does not exist"; 
            RETURN $false
        }
        Finally {
            $ErrorActionPreference=$oldPreference
        }
    } #end function test-CommandExists

    Write-Verbose "Checking and setting Invoke-SQLCmd accessibility"    

    $ret = $false 

    try {
        Push-Location
        $ret = Test-PSCommandExists "invoke-sqlcmd"        
    }
    catch {        
        Write-Host "Error : " + $_.Exception 
    }
    finally {
        Pop-Location
    }

    if($ret -eq $false) {
        Write-Verbose "Now adding Invoke-SQLCmd commandlet"
        try {
            # SQL Server 2012
            Push-Location
            Import-Module "sqlps" -DisableNameChecking -ErrorAction RaiseError                            
        }
        catch {
            Write-Verbose "Not SQL Server 2012+" 
                
            try {
                $ret = Add-PSSnapinIfNotYetAdded  "SqlServerCmdletSnapin100" -ErrorAction RaiseError
            }
            catch {
                $ret = $false 
            }   
            if($ret -eq $false) {
                Write-Host "Error : Not SQL Server 2008 or 2008 R2"                
            }
        }
        finally {
            Pop-Location
        }
        
        try {
            Push-Location
            $ret = Test-PSCommandExists "invoke-sqlcmd"        
        }
        catch {        
            Write-Error $_.Exception 
            $ret = $false
        }
        finally {
            Pop-Location
        }
        if($ret -eq $false) {
            Write-Host "Exception should not be happening : no defined invoke-sqlcmd cmdlet..." 
            return $false
        }
    }
    else {
        Write-Verbose "Commandlet Invoke-SQLCmd already available"
    }
    
    return $ret
}
