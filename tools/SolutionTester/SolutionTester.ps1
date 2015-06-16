#requires -version 2
param (
	[cmdletbinding()]
	[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $True)]
	[string]$SolutionName,
    [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $False)]
	[string]$CredentialAlias = "CurrentUser"
    <#,
    #DomainName for the SQL Services (if necessary)
    #[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
    [string]$ServerEnvironment = "Production",
    # if activated, it saves the config
    [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
    [switch]$SaveConfig #TODO    #>
)


<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>
 
#---------------------------------------------------------[Initialisations]--------------------------------------------------------
 
#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

$scriptPath 	= split-path -parent $MyInvocation.MyCommand.Definition
$configFilePath = "$scriptPath\configs\application.configs.xml"
$defaultLogPath = "$scriptPath\logs" 
$defaultLogName = $MyInvocation.MyCommand.name + ".log"

$sLogPath		= "$defaultLogPath"
$sLogName		= "$defaultLogName"
$sLogFile 		= "$defaultLogPath" + '\' + "$defaultLogName"

New-Item "$defaultLogPath" -type Directory -Force | Out-Null

#Dot Source mandatory logging Libraries
. "$scriptPath\ps-libs\Utils\Powershell-Logger.ps1"

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#Script Version
$sScriptVersion = "0.1.0"

#-----------------------------------------------------------[Functions]------------------------------------------------------------
<#

Function <FunctionName>{
	Param(
		[cmdletbinding()]		
	)	
  
	Begin{
		Log-Write -LogPath $sLogFile -LineValue "<TEXT>"
	}
  
	Process{
		Try{
			
		}
    
		Catch{
			Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
			Break
		}
	}
  
	End {
		If($?){
			Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
			Log-Write -LogPath $sLogFile -LineValue " "
		}
	}
}

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

Log-Write -LogPath $sLogFile -LineValue "Loading configuration file '$configFilePath'"

try {
    [xml]$configFile = Get-Content "$configFilePath"
}
catch {
    # Discovering the full type name of an exception
    Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception.gettype().fullName -ExitGracefully $False
    Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception.message -ExitGracefully $true 	
}

foreach ($config in $configFile.configs.config) {        
    if ($config.filename -eq $MyInvocation.MyCommand.Name) {
		
		# keep track of this configuration		
        $currentConfig = $config
		
		# getting back actual logfile 
		$newSLogPath = Resolve-Path $config.logging.logpath
		[bool] $changedLogDest = $false;
		
		if($newSLogPath -ne $null) {
			$newSLogName = $config.logging.logname
			if($newSLogName -ne $null) {
				$newSLogName = $newSLogName -replace "{COMPUTERNAME}",$env:ComputerName				
                $newSLogName = $newSLogName -replace "{DATE}",(Get-Date -uformat "%Y-%m-%d")
                $newSLogName = $newSLogName -replace "{DATESTAMP}",(Get-Date -uformat "%Y-%m-%d_%H-%M-%S")
                $newSLogName = $newSLogName -replace "{SolutionName}",$SolutionName
				$changedLogDest = $true
			}
		} 
		if($changedLogDest -eq $false) {
			Log-Error -LogPath $sLogFile -ErrorDesc "No valid logging configuration found." -ExitGracefully $false
		}
		else {            
			Log-Write -LogPath $sLogFile -LineValue "Now taking care to switch logging from $sLogFile to $newSLogPath\$newSLogName"
			$newSLogFile = "$newSLogPath\$newSLogName"
			try {
				New-Item $newSLogPath -type directory -Force | Out-Null
				if($config.logging.append -eq 0) {
					Remove-Item $newSLogFile -Force | Out-Null
				}
				Get-Content "$sLogFile" | Add-Content "$newSLogFile" 				
				Remove-Item $sLogFile -Force | Out-Null
			}
			catch {
				# Discovering the full type name of an exception
				Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception.gettype().fullName -ExitGracefully $false
				Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception.message -ExitGracefully $true				
			}
			$sLogPath = $newSLogPath
			$sLogName = $newSLogName
			$sLogFile = $newSLogFile
			
			Log-Write -LogPath $sLogPath -LineValue "Now writing to the log file defined in configuration file"
		}
		
		Write-Host "Logging in $sLogFile"
		
		# load libraries
        foreach ($curLibrary in $config.libraries.Library) {
            if ($curLibrary.Type -eq "Powershell") {
                $LibraryLocation = Resolve-Path $curLibrary.location                
                $LibraryFiles = get-childitem -Recurse -Path $LibraryLocation -include *.ps1 -exclude "Powershell-Logger.ps1" | Sort-Object                
                if ($LibraryFiles -eq $null) {
                    Log-Write -LogPath $sLogFile -LineValue "No library to load" -foreground yellow
                }
                else {
                    Log-Write -LogPath $sLogFile -LineValue "Loading files under directory $LibraryLocation"
                    
                    foreach ($LibraryFile in $LibraryFiles) {        
                        if ($LibraryFile.Directory.FullName -eq $curLibrary) {
                            $libraryName = $LibraryFile.Name           
                        }
                        else {
                            [string]$libraryName = $LibraryFile.FullName.Split($LibraryLocation,1)                            
                            if($libraryName.StartsWith('\')) {                                
                                $libraryName = $libraryName.SubString(1)
                            }
                        }
                        
                        $library = $libraryFile.FullName
                        if($currentConfig.Debug -eq 1) {
                            Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Loading library named $libraryName"
                        }
                        . "$library"
                    }
                }
            }
        }
    }
}

$logLine = "Ensuring Invoke-SQLCmd is available and loaded"
Log-Write -LogPath $sLogPath -LineValue $logLine

$ret = $false 

try {
    Push-Location
    $ret = Test-PSCommandExists "invoke-sqlcmd"
    
}
catch {
    Log-Error -LogPath "$sLogFile" -ErrorDesc $_.Exception  -ExitGracefully $false
}
finally {
    Pop-Location
}

if($ret -eq $false) {
    try {
        # SQL Server 2012
        Push-Location
        Import-Module "sqlps" -DisableNameChecking -ErrorAction RaiseError                            
    }
    catch {
        Log-Error -LogPath "$sLogFile" -ErrorDesc "Not SQL Server 2012+"  -ExitGracefully $false
            
        try {
            $ret = Add-PSSnapinIfNotYetAdded  "SqlServerCmdletSnapin100" -ErrorAction RaiseError
        }
        catch {            
            $ret = $false 
        }   
        if($ret -eq $false) {
            Log-Error -LogPath "$sLogFile" -ErrorDesc "Not SQL Server 2008 or 2008 R2"  -ExitGracefully $true
        }
    }
    finally {
        Pop-Location
    }

    $ret = Test-PSCommandExists "invoke-sqlcmd"
    if($ret -eq $false) {
        Log-Error -LogPath "$sLogFile" -ErrorDesc "Exception should not be happening : no defined invoke-sqlcmd cmdlet..."  -ExitGracefully $true
    }
}
else {
    Log-Write -LogPath "$sLogFile" -LineValue "Commandlet Invoke-SQLCmd already available"
}


<#
$logLine = "Adding actions based on command line parameters"
Log-Write -LogPath $sLogPath -LineValue $logLine
#>

Log-Write -LogPath $sLogFile -LineValue "Validating parameters"
Log-Write -LogPath $sLogFile -LineValue "    > Target server and database"
if(($config.Target | Measure-Object).Count -ne 1) {
    Log-Error -LogPath $sLogFile -ErrorDesc "Number of targets is different from expected" -ExitGracefully $true
}

if($config.Target.InstanceName -ne "" -and $config.Target.InstanceName -ne "MSSQLSERVER") {
    $TargetServer = $config.Target.HostName + "\" + $config.Target.InstanceName
}
else {
    $TargetServer = $config.Target.HostName
}

if((Test-Connection $config.Target.HostName -quiet) -ne $true) {
    Log-Error -LogPath $sLogFile -ErrorDesc "Unable to contact target server (hostname only : $($config.Target.HostName))" -ExitGracefully $true
}

$TargetDatabase = $config.Target.DatabaseName

Log-Write -LogPath $sLogPath -LineValue "        Target Server : $TargetServer"


$logLine = "Now performing tests defined in configuration file" 			
Log-Write -LogPath $sLogPath -LineValue $logLine

<#
$logLine = "Now performing actions defined in configuration file" 			
Log-Write -LogPath $sLogPath -LineValue $logLine

foreach ($action in $currentConfig.Actions.Action) {
	$logLine = "Action to perform : " + $action.Name
	Log-Write -LogPath $sLogFile -LineValue $logLine
	
	switch ($action.name) {		
		default {
			$logLine = "No handler for action " + $action.Name
			Log-Error -LogPath "$sLogFile" -ErrorDesc $logLine -ExitGracefully $false
		}
	}
}
#>

<#
if($SaveConfig) { 
    # TODO
    $logLine = "Configuration saved in file '" + "TODO" + "'" 
    Log-Write -LogPath "$sLogFile" -LineValue $logLine
}
#>

Log-Finish -LogPath $sLogFile
Write-Host ""
Write-Host ""
Write-Host "Execution completed successfully"
