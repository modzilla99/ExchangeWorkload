function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$KBArticleID
	)

	#Write-Verbose "Use this cmdlet to deliver information about command processing."

	#Write-Debug "Use this cmdlet to write debug information while troubleshooting."


	<#
	$returnValue = @{
		KBArticleID = [System.String]
	}

	$returnValue
	#>
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$KBArticleID
	)

	Write-Verbose "Installing Windows Update for KB $KBArticleID"

	#Write-Debug "Use this cmdlet to write debug information while troubleshooting."

	Import-Module PSWindowsUpdate -Force | Out-Null;

	$needsReboot = 0
	$updateList = $null

	# Install Windows Update
	if($KBArticleID.ToLower() -eq "all"){
		$updateList = Get-WUInstall -ListOnly
		Get-WUInstall -IgnoreUserInput -AcceptAll -Verbose -IgnoreReboot # -IgnoreRebootRequired
	}
	# Install by KB Article ID
	else{
		$KBArticleID = $KBArticleID.Replace("KB","")
		$KBArticleID = [Int32]$KBArticleID

		$updateList = Get-WUInstall -KBArticleID $KBArticleID -ListOnly
		Get-WUInstall -KBArticleID $KBArticleID -IgnoreUserInput -AcceptAll -Verbose -IgnoreReboot # -IgnoreRebootRequired
	}

	# Machine needs a reboot if updates are installed
	if($updateList -ne $null){
		$needsReboot = 1
	}
	
	#Include this line if the resource requires a system reboot.
	$global:DSCMachineStatus = $needsReboot
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$KBArticleID
	)
	Write-Verbose "Finding Windows Update for KB $KBArticleID if available"

	Import-Module PSWindowsUpdate -Force | Out-Null;

	$updateList = $null
	# Install Windows Update
	if($KBArticleID.ToLower() -eq "all"){
		$updateList = Get-WUInstall -ListOnly
	}
	# Install by KB Article ID
	else{
		$KBArticleID = $KBArticleID.Replace("KB","")
		$KBArticleID = [Int32]$KBArticleID
		$updateList = Get-WUInstall -KBArticleID $KBArticleID -ListOnly
		$updateList = Get-WUInstall -KBArticleID $KBArticleID -ListOnly -Verbose
		Write-Host Update List is $updateList -ForegroundColor Magenta
	}
	

	$result = [System.Boolean]$false
	# DSC needs to be executed if updates are available
	if($updateList -ne $null){
		$result = $false
		$count = $updateList.Count
		Write-Verbose "$count $KBArticleID Windows Updates are ready to be installed."
	}
	else {
		$result = $true
		Write-Verbose "No $KBArticleID Windows Updates are available to install."
	}
	
	$result
}


Export-ModuleMember -Function *-TargetResource

