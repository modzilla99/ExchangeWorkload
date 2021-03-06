function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$SourcePath,

        [parameter(Mandatory = $true)]
		[System.String]
		$DestinationDirectoryPath
	)

	#Write-Verbose "Use this cmdlet to deliver information about command processing."

	#Write-Debug "Use this cmdlet to write debug information while troubleshooting."


	
	$returnValue = @{
		SourcePath = $SourcePath
        DestinationDirectoryPath = $DestinationDirectoryPath
	}
    $returnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$SourcePath,

        [parameter(Mandatory = $true)]
		[System.String]
		$DestinationDirectoryPath
	)

    Write-Verbose "Create Destination Directory"
    New-Item -Path $DestinationDirectoryPath -ItemType Directory -Force

    $fileName = "{0}.iso" -f (Get-Date).ToString("yyyy-MM-dd-hh-mm-ss")
    $output = Join-Path $DestinationDirectoryPath $fileName

    $startTime = [System.DateTimeOffset]::Now
    Write-Verbose "Start to download file from $SourcePath"
    Get-BitsTransfer | Remove-BitsTransfer
	$downloadJob = Start-BitsTransfer -Source $SourcePath -Destination $output -DisplayName "Download" -Asynchronous -RetryInterval 60 -Priority Foreground

	while (-not ((Get-BitsTransfer -JobId $downloadJob.JobId).JobState -eq "Transferred"))
	{
		Start-Sleep -Seconds (30)
		Write-Verbose -Verbose -Message ("Waiting for downloading $SourcePath, time taken: {0}" -f ([System.DateTimeOffset]::Now - $startTime).ToString())
        Write-Verbose -Message ($downloadJob | Format-List | Out-String)
	}
    Complete-BitsTransfer -BitsJob $downloadJob
    Write-Verbose "Complete download file from $SourcePath"

    Write-Verbose "Mount the image from $output"
    $image = Mount-DiskImage -ImagePath $output -PassThru
    $driveLetter = ($image | Get-Volume).DriveLetter

    Write-Verbose "Copy files to destination directory: $DestinationDirectoryPath"
    Robocopy.exe ("{0}:" -f $driveLetter) $DestinationDirectoryPath /E | Out-Null
    
    Write-Verbose "Dismount the image from $output"
    Dismount-DiskImage -ImagePath $output
    
    Write-Verbose "Delete the temp file: $output"
    Remove-Item -Path $output -Force

}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$SourcePath,

        [parameter(Mandatory = $true)]
		[System.String]
		$DestinationDirectoryPath
	)

	Test-Path $DestinationDirectoryPath
}


Export-ModuleMember -Function *-TargetResource

