#requires -version 2
param(
    [cmdletbinding()]
    <#[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
    [string]$RepositoryServer ,
    [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
    [string]$RepositoryDatabase,
    #>
    [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
    [string]$TargetSQLInstance,
    <#[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
    [string]$OutputDatabase ,
    [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
    [string]$OutputSchemaName ,
    [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
    [string]$OutputTableName,#>
    [parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
    [string]$OutputFile
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
				$newSLogName = $newSLogName -replace "{COMPUTERNAME}",$ComputerName
				$changedLogDest = $true
			}
		} 
		if($changedLogDest -eq $false) {
			Log-Error -LogPath $sLogFile -LineValue "No valid logging configuration found." 
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
				Log-Error -LogPath $sLogFile -LineValue $_.Exception.gettype().fullName
				Log-Error -LogPath $sLogFile -LineValue $_.Exception.message
				return 1
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

$ret = Load-SQLCmd
if($ret -eq $false) {
    Log-Error -LogPath "$sLogFile" -ErrorDesc "Unable to load Invoke-SQLCmd Powershell command" -ExitGracefully $true
}

$RepositoryServer   = $config.repository.hostname
$RepositoryDatabase = $config.repository.database
$OutputDatabase     = $config.repository.OutputDatabase
$OutputSchemaName   = $config.repository.OutputSchema
$OutputTableName    = $config.repository.OutputTable

$sqlScript = "
exec [security].[getSecurityScript]
    @ServerName = '${TargetSQLInstance}',
    @DbName = NULL,
    @AsOf = NULL ,
    @OutputType = 'SCRIPT' ,
    @Debug = 1, 
    @OutputDatabaseName = '${OutputDatabase}' ,
    @OutputSchemaName = '${OutputSchemaName}' ,
    @OutputTableName = '${OutputTableName}'" 


$OutputFile = join-path "$pwd" "$OutputFile"
Log-Write -LogPath $sLogFile -LineValue "Output file : $OutputFile" 
    
$tmpLogFile =  "C:\Windows\Temp\" + $MyInvocation.MyCommand.name + "_" + (Get-Random) + ".txt"

try {
    # Log to a temp file
    Push-Location
    #Start-Transcript -Path "$tmpLogFile"         
    # instead of -QueryTimeout 0 ==> not working with SQL Server 2008 (R2) 
    #Invoke-SQLCmd -QueryTimeout ([int]::MaxValue) -Verbose -y -Query "$sqlScript" -ServerInstance "$RepositoryServer" -Database "$RepositoryDatabase" 
    # no -y
    sqlcmd.exe -t 65000 -Q "$sqlScript" -S "$RepositoryServer" -d "$RepositoryDatabase" > "$OutputFile"
}
catch {
    $logLine = "An error occurred while executing script.`nError message : " +  $_.Exception.Message
    Log-Error -LogPath "$sLogFile" -ErrorDesc $logLine -ExitGracefully $false
    $SQLerrorOccurred = $true
}
finally {					
    try {
    #    Stop-Transcript
    }
    catch { }
    Pop-Location 
    <#$lineCnt = 0
    $reader = [System.IO.File]::OpenText("$tmpLogFile")
    try {
        Remove-Item "$OutputFile" -Force 
        for(;;) {
            $line = $reader.ReadLine()
            $lineCnt++
            if($line -eq $null) { break }
            if(
                ($lineCnt -gt 7) -and  # skip header
                ("$line" -ne "**********************" ) -and 
                ("$line" -ne "Windows PowerShell Transcript End") -and 
                -not ("$line" -match "End time: [0-9]+")
            ) {
               $line -replace "VERBOSE: ","" | Out-File "$OutputFile" -Append
            }
        }
    }
    catch {
        $logLine = "An error occurred while executing script.`nError message : " +  $_.Exception.Message
        Log-Error -LogPath "$sLogFile" -ErrorDesc $logLine -ExitGracefully $false
    }
    finally {
        $reader.close()
    }
     #(Get-Content  "$tmpLogFile" ) -replace "VERBOSE: ","" | Out-File "$OutputFile"
    Remove-Item "$tmpLogFile" #>
}

Log-Finish -LogPath $sLogFile
Write-Host ""
Write-Host ""
Write-Host "Execution completed successfully"
