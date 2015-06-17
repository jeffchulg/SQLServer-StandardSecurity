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

Function Replace-TextTags { 
	Param(
		[cmdletbinding()]		
		[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $True)]
		[string]$Text,
		[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $False)]
		[string] $ScriptBasename
	)	
  
	Begin{
		Log-Write -LogPath $sLogFile -LineValue "Starting Replace-TextTags"
		if($ScriptBasename -eq $null) {
			$ScriptBasename = MyInvocation.MyCommand.Name
		}
	}
  
	Process{
		Try{
			$Text = $Text -replace "{SOLUTIONNAME}",$SolutionName
			$Text = $Text -replace "{COMPUTERNAME}",$env:ComputerName				
			
			$Text = $Text -replace "{DATE}",(Get-Date -uformat "%Y-%m-%d")
			$Text = $Text -replace "{DATESTAMP}",(Get-Date -uformat "%Y-%m-%d_%H-%M-%S")

			$Text = $Text -replace "{SCRIPT_BASENAME}"  , $ScriptBasename
			$Text = $Text -replace "{LOG_PATH}" , $sLogPath	

			$Text = $Text -replace "{TARGET_INSTANCE}"  , $TargetServer
			$Text = $Text -replace "{TARGET_DBNAME}"  , $TargetDatabase
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
		return $Text
	}
}

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
				$newSLogName = Replace-TextTags -Text $newSLogName
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
Log-Write -LogPath $sLogFile -LineValue "    > Credentials definition"


Log-Write -LogPath $sLogFile -LineValue "    > Target count"
if(($currentConfig.Target | Measure-Object).Count -ne 1) {
    Log-Error -LogPath $sLogFile -ErrorDesc "Number of targets is different from expected" -ExitGracefully $true
}

if($CredentialAlias -eq $null) {
	$CredentialAlias = "CurrentUser"
}

$CredentialsDefinition = $currentConfig.Target.Credential | Select-Object | Where-Object{$_.Alias -eq $CredentialAlias}
if($CredentialsDefinition -eq $null) { # credential alias not enlisted
	Log-Error -LogPath $sLogFile -ErrorDesc "Unrecognized Credential Alias $CredentialAlias" -ExitGracefully $true
}

# temporary condition :
if($CredentialAlias -ne "CurrentUser" ) {
	Log-Error -LogPath $sLogFile -ErrorDesc "Not yet implemented with this kind of credential ($($CredentialsDefinition.Type))" -ExitGracefully $true
}


if($currentConfig.Target.InstanceName -ne "" -and $currentConfig.Target.InstanceName -ne "MSSQLSERVER") {
    $TargetServer = $currentConfig.Target.HostName + "\" + $currentConfig.Target.InstanceName
}
else {
    $TargetServer = $currentConfig.Target.HostName
}

Log-Write -LogPath $sLogFile -LineValue "    > Target Server connectivity"

if((Test-Connection $currentConfig.Target.HostName -quiet) -ne $true) {
    Log-Error -LogPath $sLogFile -ErrorDesc "Unable to contact target server (hostname only : $($currentConfig.Target.HostName))" -ExitGracefully $true
}

Log-Write -LogPath $sLogFile -LineValue "    > Target SQL Server Database availability"

$TargetDatabase = $currentConfig.Target.DatabaseName

try {
	
	if($CredentialsDefinition.Type -eq "CurrentADUser") {
		$ret = Invoke-Sqlcmd -ServerInstance $TargetServer -Query "SELECT count(*) FROM sys.databases WHERE name = '${TargetDatabase}' and state_desc = 'ONLINE'" -ErrorAction Stop -ConnectionTimeout 3
		
		if($ret -eq $null) {
			throw "No data returned during database existence check"
		}
		
		if($TargetDatabase -ne $null) {
			$ret = Invoke-Sqlcmd -ServerInstance $TargetServer -Database $TargetDatabase -Query "SELECT 1" -ErrorAction Stop -ConnectionTimeout 3
		}
	}
	else {
		#TODO : add other credentials type handling
	}
}
catch {
	Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception.gettype().fullName -ExitGracefully $false
	Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception.message -ExitGracefully $true		
}

if($currentConfig.Debug -eq 1) {
	Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - SolutionName     : $SolutionName"
	Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Target Instance  : $TargetServer"
	Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Target Database  : $TargetDatabase"
	Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Used Credentials : $($CredentialsDefinition.Alias)"
}

Log-Write -LogPath $sLogFile -LineValue "    > Tests dependant files existence and setting values corresponding to tags in config file"

foreach ($test in $currentConfig.Tests.Test) {

	foreach($param in $test.params.param) {
		if($param.value -like "*{*}*") {
			$param.value = Replace-TextTags -Text $param.value -ScriptBasename $test.name
			#$param.value = $param.value -replace "{LOG_PATH}" , $sLogPath	
			#$param.value = $param.value -replace "{SCRIPT_BASENAME}"  , $MyInvocation.MyCommand.name
			#$param.value = $param.value -replace "{TARGET_INSTANCE}"  , $TargetServer
			#$param.value = $param.value -replace "{TARGET_DBNAME}"  , $TargetDatabase
			#$param.value = $param.value -replace "{DATESTAMP}"  , (Get-Date -uformat "%Y-%m-%d_%H-%M-%S")
			#$param.value = $param.value -replace "{DATE}"  , (Get-Date -uformat "%Y-%m-%d")
		}	
	}

	if($currentConfig.Debug -eq 1) {
		Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Current Test : $($test.Name)"	
	}
		
	$tmpFileName = $test.FileLocation
	
	if($tmpFileName -eq $null -and $test.type -ne "PSScript" -and $test.type -ne "SQLScript") {
		if($currentConfig.Debug -eq 1) {
			Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Current Test does not require any File"	
		}	
		continue
	}
	
	$ReferencedTest  = $null 
	$ReferencedParam = $null 
	
	if($tmpFileName -like "{*:*}") {		
		# reference to another test > Parameter
		if($currentConfig.Debug -eq 1) {
			Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Current Test has a FileLocation parameter which references another test"	
		}		
		
		$ReferencedTestName = ((($tmpFileName -split ":")[0] -split "{")[1])
		$ReferencedTestParam = ((($tmpFileName -split ":")[1] -split "}")[0])
		
		if($currentConfig.Debug -eq 1) {
			Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Referenced test.param is $ReferencedTestName.$ReferencedTestParam"	
		}				
		
		$ReferencedTest = $currentConfig.Tests.Test | Select-Object | Where-Object {$_.name -eq $ReferencedTestName}
		
		if($ReferencedTest -eq $null) {
			Log-Error -LogPath $sLogFile -ErrorDesc "Referenced test $ReferencedTestName does not exist in current configuration" -ExitGracefully $true		
		}
		
		if(($ReferencedTest.Params | Measure-Object).count -eq 0) {
			Log-Error -LogPath $sLogFile -ErrorDesc "Referenced test $ReferencedTestName does not have defined parameters in current configuration" -ExitGracefully $true		
		}
		
		$ReferencedParam = $ReferencedTest.Params.Param | Where-Object {$_.Name -eq $ReferencedTestParam}
		
		if($ReferencedParam -eq $null) {
			Log-Error -LogPath $sLogFile -ErrorDesc "Referenced test $ReferencedTestName does not have parameter called ${ReferencedTestParam} in current configuration" -ExitGracefully $true		
		}
		$ReferencedParam.value = Replace-TextTags -Text $ReferencedParam.value -ScriptBasename $ReferencedTest.name
		$tmpFileName = $ReferencedParam.value		
	}
	
	$tmpFileName = Replace-TextTags -Text $tmpFileName
	
	#if($tmpFileName -like "*{*}*") {		
		#$tmpFileName = $tmpFileName -replace "{LOG_PATH}" , $sLogPath	
		#$tmpFileName = $tmpFileName -replace "{SCRIPT_BASENAME}"  , $MyInvocation.MyCommand.name
		#$tmpFileName = $tmpFileName -replace "{TARGET_INSTANCE}"  , $TargetServer
		#$tmpFileName = $tmpFileName -replace "{TARGET_DBNAME}"  , $TargetDatabase
		#$tmpFileName = $tmpFileName -replace "{DATESTAMP}"  , (Get-Date -uformat "%Y-%m-%d_%H-%M-%S")
	#}	
	
	if($ReferencedParam -ne $null) {
		$ReferencedParam.Value = $tmpFileName
	}
	
	if($currentConfig.Debug -eq 1) {
		Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Current Test FileLocation is $tmpFileName"	
	}		
		
	if($tmpFileName -ne $test.FileLocation) {
		$test.FileLocation = $tmpFileName
		if($ReferencedParam -ne $null) {
			# no need to check if it exists.. It's not necessarily the case !
			continue
		}
	}	

	if(($tmpFileName -eq $null) -or ((Test-Path $tmpFileName) -ne $true)) {
		Log-Error -LogPath $sLogFile -ErrorDesc "Test $($test.Name) : FileLocation $tmpFileName does not exist" -ExitGracefully $true
	}
}

$logLine = "Now performing tests defined in configuration file" 			
Log-Write -LogPath $sLogFile -LineValue $logLine

$ErrorCountInTest = 0
$ErrorCountST     = 0 # error count relative to Solution Tester

foreach ($test in ($currentConfig.Tests.Test | Sort-Object @{e={$_.order -as [int]}})) {
	$logLine = "    > " + $test.Name
	Log-Write -LogPath $sLogFile -LineValue $logLine
	
	if(
		$abortedTests -eq $true -and 
		$test.runEvenIfPreviousError -ne "true" -and 
		$abortedTestOrder -lt $test.StartFromOrder
	) {
		continue
	}
	
	$errorOccurredDuringTest 	= $false
	
	switch($test.Type) {
		"SQLScript" {
			Log-Write -LogPath $sLogFile -LineValue "        => SQL SCRIPT $($test.FileLocation)"
			
			$tmpLogFile			=  "C:\Windows\Temp\" + $MyInvocation.MyCommand.name + "_" + (Get-Random) + ".txt"			
			
			try {
				# Log to a temp file
				Push-Location
				Start-Transcript -Path "$tmpLogFile"
				if($TargetDatabase -eq $null) {
					$ret = Invoke-SQLCmd -Verbose -inputfile $test.FileLocation -ServerInstance "$TargetServer"
				}
				else {
					$ret = Invoke-SQLCmd -Verbose -inputfile $test.FileLocation -ServerInstance "$TargetServer" -Database $TargetDatabase
				}
			}
			catch {
				$logLine = "An error occurred while executing script.`nError message :`n" +  $_.Exception.Message + "`nStack Trace :`n" + $_.Exception.StackTrace
				Log-Error -LogPath "$sLogFile" -ErrorDesc $logLine -ExitGracefully $false
				$errorOccurredDuringTest = $true
				$ErrorCountInTest = $ErrorCountInTest + 1
			}
			finally {					
				try {
					Stop-Transcript
				}
				catch { }
				Pop-Location
				
			}
			$padding = "    "*3
			$logLine = "`n`n${padding}:::::::::::::::::::::::::: SQLCMD LOG ::::::::::::::::::::::::::::::::`n`n"
			Log-Write -LogPath $sLogFile -LineValue $logLine
			
			foreach ($logLine in (Get-Content "$tmpLogFile")) {
				if($logLine -like "VERBOSE:*") {
					$logLine = $logLine -replace "VERBOSE:",""
				}
				
				Log-Write -LogPath $sLogFile -LineValue "${padding}$logLine"
				
				if(
					$logLine -like "Msg [0-9]*, Level [0-9]*, State [0-9]*, Line [0-9]*" -or 
					$logLine -like "*CategoryInfo*Invoke-Sqlcmd*SqlPowerShellSqlExecutionException*"
				) {
					$errorOccurredDuringTest = $true
					$ErrorCountInTest        = $ErrorCountInTest + 1
				}
			}
			
			$logLine = "`n`n${padding}:::::::::::::::::::::::::END OF SQLCMD LOG::::::::::::::::::::::::::::`n`n"
			Log-Write -LogPath $sLogFile -LineValue $logLine
			
			Remove-Item "$tmpLogFile"
		}
		"PSScript" {
			Log-Write -LogPath $sLogFile -LineValue "        => POWERSHELL SCRIPT $($test.FileLocation)"
			$PSScriptCommand = $test.FileLocation 
			
			foreach ($param in $test.Params.Param) {
				$PSScriptCommand = $PSScriptCommand + " -" + $param.Name + " '"+ $param.Value + "'"
			}
			
			if($currentConfig.Debug -eq 1) {
				Log-Write -LogPath $sLogFile -LineValue "[DEBUG] - Generated Command : & $PSScriptCommand"
			}
			
			#try {
				
		#		Invoke-Command -ScriptBlock { $PSScriptCommand }
			
		#	}
			
		#	catch {
			
		#	}
			
		}
		default {
			$logLine = "Unknown Test type '$($test.Type)' " + $action.Name
			Log-Error -LogPath "$sLogFile" -ErrorDesc $logLine -ExitGracefully $false
			
			$ErrorCountST = $ErrorCountST + 1
			$test.Status -eq "SKIPPED"
		}		
	}
	
	if ( $errorOccurredDuringTest -eq $true -and ($test.mustSucceed -eq "true")) {
		$logLine = "Mandatory test didn't succeed. Aborting normal execution mode"
		Log-Error -LogPath "$sLogFile" -ErrorDesc $logLine -ExitGracefully $false
		$abortedTests = $true
		if($abortedTestOrder -eq $null) {
			$abortedTestOrder = $test.Order	
		}
	}
}

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

Write-Host ""
Write-Host ""

if($ErrorCountST + $ErrorCountInTest -eq 0) {
	Write-Host "Execution completed successfully"
}
else {
	Write-Host "Some errors occurred. Check logfile for further informations."
	if($ErrorCountST -ne 0) {
		Write-Host "Some of the errors are related to SolutionTester."
	}
	if($ErrorCountInTest -ne 0) {
		Write-Host "There are errors related to the tests."
	} 
}

Log-Finish -LogPath $sLogFile