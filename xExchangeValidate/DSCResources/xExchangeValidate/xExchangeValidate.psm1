function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$testName
	)
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$testName
	)

	Write-Verbose "Validating exchange server setup for $testName tests"
	Set-ExecutionPolicy Unrestricted -Force -Confirm:0 -ErrorAction SilentlyContinue;

	if($testName.ToLower() -eq "all"){
		
		$fqdn = "$env:COMPUTERNAME.$env:USERDNSDOMAIN"
		$psv = $PSVersionTable
		Write-Verbose $psv

		# Start Exchange Management Shell PSSession
		#$ps = New-PSSession -ConfigurationName microsoft.exchange -name ex -ConnectionURI http://$fqdn/powershell/ -Authentication Kerberos -AllowRedirection
		#Import-PSSession $ps
		Write-Verbose "Adding snap-in Microsoft.Exchange.Management.PowerShell.E2010 for Powershell compatibility"
		Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
		& 'E:\Exchange\Bin\RemoteExchange.ps1'
		Write-Verbose "Loading Remote Exchange: Bin\RemoteExchange.ps1"

		$exchangeServer = Get-ExchangeServer
		$exchangeServerName = $exchangeServer.Name
		$exchangeServerRole = $exchangeServer.ServerRole
		$exchangeServerDomain = $exchangeServer.Domain
		$exchangeServerFQDN = $exchangeServer.FQDN
		$exchangeUser = $env:USERNAME
		$exchangeUserEmail = "$exchangeUser@$exchangeServerDomain"
		$mailboxStats = Get-MailboxStatistics -Identity $exchangeUser

		if($exchangeServerName -ne $null){
			Write-Verbose "Exchange server $exchangeServerName is successfully installed with domain name $exchangeServerDomain and roles $exchangeServerRole"
		}

		# Send e-mail
		Send-MailMessage -Body "Test Exchange 2016 setup" -Subject "Exchange 2016 is Setup!" -To $exchangeUserEmail -From $exchangeUserEmail -SmtpServer $exchangeServerFQDN -DeliveryNotificationOption OnSuccess, OnFailure, Delay

		# Check e-mail count
		$retryCount = 10
		while($retryCount -gt 0){
			Start-Sleep -Seconds 15
			$mailboxStats2 = Get-MailboxStatistics -Identity $exchangeUser
			if($mailboxStats2.ItemCount -gt $mailboxStats.ItemCount){
				Write-Verbose "Exchange server send mail message successfull for user $exchangeUserEmail"
				$retryCount = 0
				break
			}
			$retryCount--
		}

		# End Exchange Management Shell PSSession
		Remove-PSSession $ps
	}
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$testName
	)

	$result = [System.Boolean]$false
	
	$result
}


Export-ModuleMember -Function *-TargetResource

