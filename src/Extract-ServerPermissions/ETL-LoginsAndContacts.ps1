function ETL-LoginsAndContacts {
<#
	.SYNOPSIS
	   	

	.DESCRIPTION
	    
		
	.NOTES
	    Version      			: 
	    Rights Required			: 	    				
	    Author(s)    			: 
	    Dedicated Post			: 
	    Disclaimer   			: You running this script means you won't blame me if this breaks your stuff.

	
	.EXAMPLE

	
		Description
		-----------
	
	
	.LINK
	
	.INPUTS
	
	
	#Requires -Version 2.0
	#>
	
	param (
		[cmdletbinding()]
		[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
		[string]$ComputerName = $env:ComputerName,
		[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
		[string]$InventoryServerName,
		[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
		[string]$InventoryDbName,
		[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
		[bool]$DebugMode = $false
    )
	
	if($DebugMode) {
		Write-Host 'test'
	}
	
	if ( (Get-PSSnapin -Name SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue) -eq $null ) {
		Add-PSSnapin SqlServerCmdletSnapin100
    }	
	
	if ( (Get-PSSnapin -Name SqlServerProviderSnapin100 -ErrorAction SilentlyContinue) -eq $null ) {
		Add-PSSnapin SqlServerProviderSnapin100
    }
	
	$sqlFile = Resolve-Path ".\ETL-LoginsAndContacts.sql"
	$debugStr = 0
	if($DebugMode) {
		$debugStr = 1
	}
	Get-Content $sqlFile | Foreach-Object { $_ -replace "'<INVENTORY_SERVERNAME>'", "'$InventoryServerName'"} | Foreach-Object {$_ -replace  "'<DEBUG>'",$debugStr } |out-file "$sqlFile.$ComputerName.sql"
	
	osql -E -s $ComputerName -i "$sqlFile.$ComputerName.sql" -o "$sqlFile.test.sql"

}
# ETL-LoginsAndContacts -ComputerName SI-S-SERV236 -InventoryServerName SI-S-SERV307