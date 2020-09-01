#
# Copyright="© Microsoft Corporation. All rights reserved."
#

configuration InstallAndConfigureExchange
{
	param
    (
		[Parameter(Mandatory=$true)]
		[String]$DomainName,

		[Parameter(Mandatory=$true)]
		[String]$StorageSize,

		[Parameter(Mandatory=$true)]
		[PSCredential]$VMAdminCreds,

		[Parameter(Mandatory=$true)]
		[String]$Location,

		[Parameter(Mandatory=$true)]
		[String]$Company,


		[Parameter(Mandatory=$true)]
		[PSCredential]$MaxMustermannUserCreds,
		
		[Parameter(Mandatory=$true)]
		[PSCredential]$ErikaMustermannUserCreds,

		[Parameter(Mandatory=$true)]
		[PSCredential]$JohnDoeUserCreds,

		[Parameter(Mandatory=$true)]
		[PSCredential]$KarlAndersUserCreds,
		
		[Parameter(Mandatory=$true)]
		[PSCredential]$VeronikaSpulaUserCreds,

		[Parameter(Mandatory=$true)]
		[PSCredential]$LeaMayerUserCreds,


		[Parameter(Mandatory=$true)]
		[PSCredential]$CelinaHerzUserCreds,
		
		[Parameter(Mandatory=$true)]
		[PSCredential]$WolfgangErnstUserCreds,

		[Parameter(Mandatory=$true)]
		[PSCredential]$JohannFrickUserCreds,

		[Parameter(Mandatory=$true)]
		[PSCredential]$SaschaHarzUserCreds,
		
		[Parameter(Mandatory=$true)]
		[PSCredential]$WiolettaLonskaUserCreds,

		[Parameter(Mandatory=$true)]
		[PSCredential]$RobertJungUserCreds




	)

	$DomainCreds = [System.Management.Automation.PSCredential]$DomainFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($VMAdminCreds.UserName)", $VMAdminCreds.Password)

	$MaxMustermannCreds =  [System.Management.Automation.PSCredential]$MaxMustermannUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($MaxMustermannUserCreds.UserName)", $MaxMustermannUserCreds.Password)
	$ErikaMustermannCreds =  [System.Management.Automation.PSCredential]$ErikaMustermannUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($ErikaMustermannUserCreds.UserName)", $ErikaMustermannUserCreds.Password)
	$JohnDoeCreds =  [System.Management.Automation.PSCredential]$JohnDoeUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($JohnDoeUserCreds.UserName)", $JohnDoeUserCreds.Password)
	$KarlAndersCreds =  [System.Management.Automation.PSCredential]$KarlAndersUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($KarlAndersUserCreds.UserName)", $KarlAndersUserCreds.Password)
	$VeronikaSpulaCreds =  [System.Management.Automation.PSCredential]$VeronikaSpulaUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($VeronikaSpulaUserCreds.UserName)", $VeronikaSpulaUserCreds.Password)
	$LeaMayerCreds =  [System.Management.Automation.PSCredential]$LeaMayerUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($LeaMayerUserCreds.UserName)", $LeaMayerUserCreds.Password)
	$CelinaHerzCreds =  [System.Management.Automation.PSCredential]$CelinaHerzUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($CelinaHerzUserCreds.UserName)", $CelinaHerzUserCreds.Password)
	$WolfgangErnstCreds =  [System.Management.Automation.PSCredential]$WolfgangErnstUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($WolfgangErnstUserCreds.UserName)", $WolfgangErnstUserCreds.Password)
	$JohannFrickCreds =  [System.Management.Automation.PSCredential]$JohannFrickUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($JohannFrickUserCreds.UserName)", $JohannFrickUserCreds.Password)
	$SaschaHarzCreds =  [System.Management.Automation.PSCredential]$SaschaHarzUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($SaschaHarzUserCreds.UserName)", $SaschaHarzUserCreds.Password)
	$WiolettaLonskaCreds =  [System.Management.Automation.PSCredential]$WiolettaLonskaUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($WiolettaLonskaUserCreds.UserName)", $WiolettaLonskaUserCreds.Password)
	$RobertJungCreds =  [System.Management.Automation.PSCredential]$RobertJungUserFQDNCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($RobertJungUserCreds.UserName)", $RobertJungUserCreds.Password)





	Import-DscResource -ModuleName 'PSDesiredStateConfiguration';
	Import-DscResource -ModuleName xActiveDirectory;
	Import-DscResource -ModuleName xDisk;
	Import-DscResource -ModuleName xDownloadFile;
	Import-DscResource -ModuleName xDownloadISO;
    Import-DscResource -ModuleName xExchange;
	Import-DscResource -ModuleName xExchangeValidate;
	Import-DscResource -ModuleName xExtract;
	Import-DscResource -ModuleName xInstaller;
	Import-DscResource -ModuleName xPendingReboot;
	Import-DscResource -ModuleName xPSDesiredStateConfiguration;
	Import-DscResource -ModuleName xPSWindowsUpdate;

	# Downloaded file storage location
	$downloadPath = "$env:SystemDrive\DownloadsForDSC";
	$exchangeInstallerPath = "$env:SystemDrive\InstallerExchange";
	$diskNumber = 2;
	#Information for OU Structure
	[string]$domain,$tld = $DomainName.split(".")
	Node localhost
    {
		xWaitforDisk Disk2
        {
            DiskNumber = $diskNumber
            RetryIntervalSec = 60
            RetryCount = 60
        }
        xDisk Volume
        {
			DiskNumber = $diskNumber
            DriveLetter = 'F'
			DependsOn = '[xWaitforDisk]Disk2'
        }

		# Reboot node if necessary
		xPendingReboot RebootPostInstall
        {
            Name      = "RebootTutGut"
			DependsOn = "[xDisk]Volume"
        }
		# Install Exchange 2016 Pre-requisits | Reference: https://technet.microsoft.com/en-us/library/bb691354(v=exchg.160).aspx
		# Active Directory
		WindowsFeature RSATADDS {
			Name = "RSAT-ADDS"
            Ensure = "Present"
			DependsOn = "[xPendingReboot]RebootPostInstall"
		}
		# Media Foundation
		WindowsFeature MediaFoundationInstall 
        {
            Name = "Server-Media-Foundation"
			Ensure = "Present"
			DependsOn = "[WindowsFeature]RSATADDS"
        }
		xPendingReboot RebootPostMediaFoundationInstall
        {
           	Name = "AfterADDSInstall"
           	DependsOn = "[WindowsFeature]MediaFoundationInstall"
        }
		WindowsFeature Net45Features {
			Name = "NET-Framework-45-Features"
            Ensure = "Present"
			DependsOn = "[xPendingReboot]RebootPostMediaFoundationInstall"
		}
		WindowsFeature NETWCFHTTPActivation45{
			Name = "NET-WCF-HTTP-Activation45"
			Ensure = "Present"
			DependsOn = "[WindowsFeature]Net45Features"
		}

		WindowsFeature RPCOverHTTPProxy {
			Name = "RPC-over-HTTP-proxy"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]NETWCFHTTPActivation45"
		}
		WindowsFeature RSATClustering {
			Name = "RSAT-Clustering"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]RPCOverHTTPProxy"
		}
		WindowsFeature RSATClusteringCmd {
			Name = "RSAT-Clustering-CmdInterface"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]RSATClustering"
		}
		WindowsFeature RSATClusteringMgmt {
			Name = "RSAT-Clustering-Mgmt"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]RSATClusteringCmd"
		}
		WindowsFeature RSATClusteringPS {
			Name = "RSAT-Clustering-PowerShell"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]RSATClusteringMgmt"
		}
		WindowsFeature WASProcessModel {
			Name = "WAS-Process-Model"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]RSATClusteringPS"
		}
		WindowsFeature WebAspNet45 {
			Name = "Web-Asp-Net45"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WASProcessModel"
		}
		WindowsFeature WebBasicAuth {
			Name = "Web-Basic-Auth"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebAspNet45"
		}
		WindowsFeature WebClientAuth {
			Name = "Web-Client-Auth"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebBasicAuth"
		}
		WindowsFeature WebDigestAuth {
			Name = "Web-Digest-Auth"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebClientAuth"
		}
		WindowsFeature WebDirBrowsing {
			Name = "Web-Dir-Browsing"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebDigestAuth"
		}
		WindowsFeature WebDynCompression {
			Name = "Web-Dyn-Compression"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebDirBrowsing"
		}
		WindowsFeature WebHttpErrors {
			Name = "Web-Http-Errors"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebDynCompression"
		}
		WindowsFeature WebHttpLogging {
			Name = "Web-Http-Logging"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebHttpErrors"
		}
		WindowsFeature WebHttpRedirect {
			Name = "Web-Http-Redirect"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebHttpLogging"
		}
		WindowsFeature WebHttpTracing {
			Name = "Web-Http-Tracing"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebHttpRedirect"
		}
		WindowsFeature WebISAPIExt {
			Name = "Web-ISAPI-Ext"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebHttpTracing"
		}
		WindowsFeature WebISAPIFilter {
			Name = "Web-ISAPI-Filter"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebISAPIExt"
		}
		WindowsFeature WebLgcyMgmtConsole {
			Name = "Web-Lgcy-Mgmt-Console"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebISAPIFilter"
		}
		WindowsFeature WebMetabase {
			Name = "Web-Metabase"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebLgcyMgmtConsole"
		}
		WindowsFeature WebMgmtConsole {
			Name = "Web-Mgmt-Console"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebMetabase"
		}
		WindowsFeature WebMgmtService {
			Name = "Web-Mgmt-Service"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebMgmtConsole"
		}
		WindowsFeature WebNetExt45 {
			Name = "Web-Net-Ext45"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebMgmtService"
		}
		WindowsFeature WebRequestMonitor {
			Name = "Web-Request-Monitor"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebNetExt45"
		}
		WindowsFeature WebServer {
			Name = "Web-Server"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebRequestMonitor"
		}
		WindowsFeature WebStatCompression {
			Name = "Web-Stat-Compression"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebServer"
		}
		WindowsFeature WebStaticContent {
			Name = "Web-Static-Content"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebStatCompression"
		}
		WindowsFeature WebWindowsAuth {
			Name = "Web-Windows-Auth"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebStaticContent"
		}
		WindowsFeature WebWMI {
			Name = "Web-WMI"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebWindowsAuth"
		}
		WindowsFeature WindowsIdentityFoundation {
			Name = "Windows-Identity-Foundation"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WebWMI"
		}
		# Edge Transport Server Role
		WindowsFeature ADLDS {
			Name = "ADLDS"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]WindowsIdentityFoundation"
		}
		# DNS
		WindowsFeature DNS 
        {
            Name = "DNS"
			Ensure = "Present"
			DependsOn = "[WindowsFeature]ADLDS"
        }

		WindowsFeature RSATDNSServer {
			Name = "RSAT-DNS-Server"
            Ensure = "Present"
			DependsOn = "[WindowsFeature]DNS"
		}

		# Reboot node if necessary
		xPendingReboot AfterFeatureInstall
		{
		Name      = "AfterFeatureInstall"
		DependsOn = "[WindowsFeature]RSATDNSServer"
		}

		# Download Unified Communication Manager API 4.0
		xDownloadFile DownloadUCMA4
		{
			SourcePath = "https://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe"
			FileName = "UcmaRuntimeSetup.exe"
			DestinationDirectoryPath = $downloadPath
			DependsOn = "[xPendingReboot]AfterFeatureInstall"
		}
		# Install Unified Communication Manager API 4.0
		Package UCMA {
			Ensure    = 'Present'
			Name      = 'Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit'
			Path      = 'C:\DownloadsForDSC\UcmaRuntimeSetup.exe'
			ProductID = 'ED98ABF5-B6BF-47ED-92AB-1CDCAB964447'
			Arguments = '/q'
			DependsOn = "[xDownloadFile]DownloadUCMA4"
		}
		# Reboot node if necessary
		xPendingReboot RebootPostInstallUCMA4
		{
			Name      = "AfterUCMA4"
			DependsOn = "[Package]UCMA"
		}
				
	
		# Download Visual C++ Redistributable Packages for Visual Studio 2013 Download
				
		xDownloadFile Downloadvcredistx64
		{
			SourcePath = "https://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe"
			FileName = "vcredist_x64.exe"
			DestinationDirectoryPath = $downloadPath
			DependsOn = "[xPendingReboot]RebootPostInstallUCMA4"
		}
		# Install Visual C++ Redistributable Packages for Visual Studio 2013
		xInstaller Installvcredistx64
		{
			Path = "$downloadPath\vcredist_x64.exe"
			Arguments = "/install /passive /norestart"
			RegistryKey = "NA"
			DependsOn = "[xDownloadFile]Downloadvcredistx64"
		}
		# Reboot node if necessary
		xPendingReboot RebootPostInstallvcredistx64
		{
			Name      = "Aftervcredistx64"
			DependsOn = "[xInstaller]Installvcredistx64"
		}

		# Active Directory Domain Service
		WindowsFeature ADDSInstall 
        {
            Name = "AD-Domain-Services"
			Ensure = "Present"
			DependsOn = "[xPendingReboot]RebootPostInstallvcredistx64"
        }
		xPendingReboot RebootPostADDSInstall
        {
           	Name = "AfterADDSInstall"
           	DependsOn = "[WindowsFeature]ADDSInstall"
        }
		# AD Domain creation needs a reboot
		xADDomain FirstDS 
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainCreds
			SafemodeAdministratorPassword = $DomainCreds
			DatabasePath = "$env:SystemDrive\NTDS"
            LogPath = "$env:SystemDrive\NTDS"
            SysvolPath = "$env:SystemDrive\SYSVOL"
			DependsOn = "[xPendingReboot]RebootPostADDSInstall"
        }
		# Reboot node if necessary
		xPendingReboot RebootPostFirstDS
        {
            Name      = "AfterFirstDS"
            DependsOn = "[xADDomain]FirstDS"
        }
		
        #Create First OU
        xADOrganizationalUnit FirstOU
        {
        	Name = $Company
        	Path = "dc=$domain,dc=$tld"
        	DependsOn = "[xPendingReboot]RebootPostFirstDS"
        }
              
        # Create Branch
        xADOrganizationalUnit Branch
        {
        	Name = 'Branch'
        	Path = "ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]FirstOU'
        }
        # Create Branch Kiel
        xADOrganizationalUnit BranchKiel
        {
        	Name = 'Kiel'
        	Path = "ou=branch,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]Branch'
        }

		xADOrganizationalUnit BranchUserKiel
		{
        	Name = 'Users'
        	Path = "ou=kiel,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]BranchKiel'
        }

		xADOrganizationalUnit BranchGroupKiel
		{
        	Name = 'Groups'
        	Path = "ou=kiel,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]BranchKiel'
        }

		xADOrganizationalUnit BranchComputerKiel
		{
        	Name = 'Computers'
        	Path = "ou=kiel,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]BranchKiel'
        }

        #Create Branch Hamburg
        xADOrganizationalUnit BranchHamburg
        {
        	Name = 'Hamburg'
        	Path = "ou=branch,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]Branch'
        }

		xADOrganizationalUnit BranchUserHamburg
		{
        	Name = 'Users'
        	Path = "ou=Hamburg,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]BranchHamburg'
        }

		xADOrganizationalUnit BranchGroupHamburg
		{
        	Name = 'Groups'
        	Path = "ou=Hamburg,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]BranchHamburg'
        }

		xADOrganizationalUnit BranchComputerHamburg
		{
        	Name = 'Computers'
        	Path = "ou=Hamburg,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]BranchHamburg'
        }

        #Create Administration OU

        #Create Branch
        xADOrganizationalUnit Administration
        {
        	Name = 'Administration'
        	Path = "ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]FirstOU'
        }

        xADOrganizationalUnit AdministrationServiceAccount
        {
        	Name = 'ServiceAccounts'
        	Path = "ou=Administration,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]Administration'
        }

        xADOrganizationalUnit AdministrationContacts
        {
        	Name = 'Contacts'
        	Path = "ou=Administration,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]Administration'
        }

        xADOrganizationalUnit Administrationdistributionlists
        {
        	Name = 'DistributionLists'
        	Path = "ou=Administration,ou=$Company,dc=$domain,dc=$tld"
       	 	DependsOn = '[xADOrganizationalUnit]Administration'
        }

        xADOrganizationalUnit AdministrationGroups
        {
        	Name = 'Groups'
        	Path = "ou=Administration,ou=$Company,dc=$domain,dc=$tld"
        	DependsOn = '[xADOrganizationalUnit]Administration'
		}
		

		xADUser MaxMustermann
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
        	Path  = "ou=Users,ou=kiel,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	Username = 'MMustermann'
			DisplayName = 'Max Mustermann'
			CommonName = 'Max Mustermann'
			UserPrincipalName  = "mmustermann@$DomainName"
        	GivenName  = 'Max'
        	Surname = 'Mustermann'
        	StreetAddress = 'Weg 1'
        	City = 'Kiel'
			PostalCode  = '24145'
			Country = 'DE'
			Company = $Company
			Office = '10'
			JobTitle = 'CEO'
			OfficePhone = '0049 431 555 123 100'
			MobilePhone = '0049 160 555 123 100'
        	Password = $MaxMustermannCreds
        	DependsOn = '[xADOrganizationalUnit]BranchUserKiel'
		}
		
		xADUser ErikaMustermann
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
        	Path  = "ou=Users,ou=kiel,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	Username = 'EMustermann'
			DisplayName = 'Erika Mustermann'
			CommonName = 'Erika Mustermann'
			UserPrincipalName  = "emustermann@$DomainName"
        	GivenName  = 'Erika'
        	Surname = 'Mustermann'
        	StreetAddress = 'Weg 1'
        	City = 'Kiel'
			PostalCode  = '24145'
			Country = 'DE'
			Company = $Company
			Office = '10'
			JobTitle = 'Geschäftsführerin'
			Department = 'Marketing'
			OfficePhone = '0049 431 555 123 500'
			MobilePhone = '0049 160 555 123 500'
        	Password = $ErikaMustermannCreds
        	DependsOn = '[xADOrganizationalUnit]BranchUserKiel'
		}
		
		xADUser JohnDoe
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
        	Path  = "ou=Users,ou=kiel,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	Username = 'JDoe'
			DisplayName = 'John Doe'
			CommonName = 'John Doe'
			UserPrincipalName  = "jdoe@$DomainName"
        	GivenName  = 'John'
        	Surname = 'Doe'
        	StreetAddress = 'Weg 1'
        	City = 'Kiel'
			PostalCode  = '24145'
			Country = 'DE'
			Company = $Company
			Office = '15'
			JobTitle = 'Leiter Marketing'
			Department = 'Marketing'
			OfficePhone = '0049 431 555 123 510'
			MobilePhone = '0049 160 555 123 510'
			Password = $JohnDoeCreds
			DependsOn = '[xADOrganizationalUnit]BranchUserKiel'
		}

		xADUser KarlAnders
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
        	Path  = "ou=Users,ou=kiel,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	Username = 'KAnders'
			DisplayName = 'Karl Anders'
			CommonName = 'Karl Anders'
			UserPrincipalName  = "kanders@$DomainName"
        	GivenName  = 'Karl'
        	Surname = 'Anders'
        	StreetAddress = 'Weg 1'
        	City = 'Kiel'
			PostalCode  = '24145'
			Country = 'DE'
			Company = $Company
			Office = '15'
			JobTitle = 'Artist'
			Department = 'Marketing'
			OfficePhone = '0049 431 555 123 511'
			MobilePhone = '0049 160 555 123 511'
			Password = $KarlAndersCreds
			DependsOn = '[xADOrganizationalUnit]BranchUserKiel'
		}

		xADUser VeronikaSpula
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
        	Path  = "ou=Users,ou=kiel,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	Username = 'VSpula'
			DisplayName = 'Veronika Spula'
			CommonName = 'Veronika Spula'
			UserPrincipalName  = "vspula@$DomainName"
        	GivenName  = 'Veronika'
        	Surname = 'Spula'
        	StreetAddress = 'Weg 1'
        	City = 'Kiel'
			PostalCode  = '24145'
			Country = 'DE'
			Company = $Company
			Office = '15'
			JobTitle = 'Artist'
			Department = 'Marketing'
			OfficePhone = '0049 431 555 123 512'
			MobilePhone = '0049 160 555 123 512'
			Password = $VeronikaSpulaCreds
			DependsOn = '[xADOrganizationalUnit]BranchUserKiel'
		}

		xADUser LeaMayer
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
        	Path  = "ou=Users,ou=kiel,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	Username = 'LMayer'
			DisplayName = 'Lea Mayer'
			CommonName = 'Lea Mayer'
			UserPrincipalName  = "lmayer@$DomainName"
        	GivenName  = 'Lea'
        	Surname = 'Mayer'
        	StreetAddress = 'Weg 1'
        	City = 'Kiel'
			PostalCode  = '24145'
			Country = 'DE'
			Company = $Company
			Office = '15'
			JobTitle = 'Artist'
			Department = 'Marketing'
			OfficePhone = '0049 431 555 123 513'
			MobilePhone = '0049 160 555 123 513'
			Password = $LeaMayerCreds
			DependsOn = '[xADOrganizationalUnit]BranchUserKiel'
		}
       
		xADUser CelinaHerz
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
    	    Path  = "ou=Users,ou=Hamburg,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
    	    Username = 'CHerz'
			DisplayName = 'Celina Herz'
			CommonName = 'Celina Herz'
			UserPrincipalName  = "cherz@$DomainName"
    	    GivenName  = 'Celina'
    	    Surname = 'Herz'
    	    StreetAddress = 'Ring 1'
    	    City = 'Hamburg'
			PostalCode  = '20257'
			Country = 'DE'
			Company = $Company
			Office = '10'
			JobTitle = 'Leitung - Hamburg'
			OfficePhone = '0049 040 655 123 100'
			MobilePhone = '0049 160 655 123 100'
    	    Password = $CelinaHerzCreds
    	    DependsOn = '[xADOrganizationalUnit]BranchUserHamburg'
		}
		
		xADUser WolfgangErnst
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
   	 	    Path  = "ou=Users,ou=Hamburg,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
    	    Username = 'WErnst'
			DisplayName = 'Wolfgang Ernst'
			CommonName = 'Wolfgang Ernst'
			UserPrincipalName  = "wernst@$DomainName"
    	    GivenName  = 'Wolfgang'
    	    Surname = 'Ernst'
    	    StreetAddress = 'Ring 1'
    	    City = 'Hamburg'
			PostalCode  = '20257'
			Country = 'DE'
			Company = $Company
			Office = '10'
			JobTitle = 'Artist'
			Department = 'Marketing'
			OfficePhone = '0049 040 655 123 500'
			MobilePhone = '0049 160 655 123 500'
    	    Password = $WolfgangErnstCreds
    	    DependsOn = '[xADOrganizationalUnit]BranchUserHamburg'
		}
		
		xADUser JohannFrick
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
    	    Path  = "ou=Users,ou=Hamburg,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
    	    Username = 'JFrick'
			DisplayName = 'Johann Frick'
			CommonName = 'Johann Frick'
			UserPrincipalName  = "jfrick@$DomainName"
    	    GivenName  = 'Johann'
    	    Surname = 'Frick'
    	    StreetAddress = 'Ring 1'
    	    City = 'Hamburg'
			PostalCode  = '20257'
			Country = 'DE'
			Company = $Company
			Office = '15'
			JobTitle = 'Artist'
			Department = 'Marketing'
			OfficePhone = '0049 040 655 123 510'
			MobilePhone = '0049 160 655 123 510'
			Password = $JohannFrickCreds
			DependsOn = '[xADOrganizationalUnit]BranchUserHamburg'
		}

		xADUser SaschaHarz
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
    	    Path  = "ou=Users,ou=Hamburg,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
    	    Username = 'SHarz'
			DisplayName = 'Sascha Harz'
			CommonName = 'Sascha Harz'
			UserPrincipalName  = "sharz@$DomainName"
    	    GivenName  = 'Sascha'
    	    Surname = 'Harz'
    	    StreetAddress = 'Ring 1'
    	    City = 'Hamburg'
			PostalCode  = '20257'
			Country = 'DE'
			Company = $Company
			Office = '15'
			JobTitle = 'Artist'
			Department = 'Marketing'
			OfficePhone = '0049 040 655 123 511'
			MobilePhone = '0049 160 655 123 511'
			Password = $SaschaHarzCreds
			DependsOn = '[xADOrganizationalUnit]BranchUserHamburg'
		}

		xADUser WiolettaLonska
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
      		Path  = "ou=Users,ou=Hamburg,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
       		Username = 'WLonska'
			DisplayName = 'Wioletta Lonska'
			CommonName = 'Wioletta Lonska'
			UserPrincipalName  = "wlonska@$DomainName"
      		GivenName  = 'Wioletta'
      		Surname = 'Lonska'
      		StreetAddress = 'Ring 1'
      		City = 'Hamburg'
			PostalCode  = '20257'
			Country = 'DE'
			Company = $Company
			Office = '15'
			JobTitle = 'Artist'
			Department = 'Marketing'
			OfficePhone = '0049 040 655 123 512'
			MobilePhone = '0049 160 655 123 512'
			Password = $WiolettaLonskaCreds
			DependsOn = '[xADOrganizationalUnit]BranchUserHamburg'
		}

		xADUser RobertJung
        {
			DomainName = $DomainName
			DomainAdministratorCredential = $domainCred
        	Path  = "ou=Users,ou=Hamburg,ou=Branch,ou=$Company,dc=$domain,dc=$tld"
        	Username = 'RJung'
			DisplayName = 'Robert Jung'
			CommonName = 'Robert Jung'
			UserPrincipalName  = "rjung@$DomainName"
        	GivenName  = 'Robert'
        	Surname = 'Jung'
        	StreetAddress = 'Ring 1'
        	City = 'Hamburg'
			PostalCode  = '20257'
			Country = 'DE'
			Company = $Company
			Office = '15'
			JobTitle = 'Artist'
			Department = 'Marketing'
			OfficePhone = '0049 040 655 123 513'
			MobilePhone = '0049 160 655 123 513'
			Password = $RobertJungCreds
			DependsOn = '[xADOrganizationalUnit]BranchUserHamburg'
		}


# Install Exchange 2016 CU17
        xExchInstall InstallExchange
        {
            Path = "$exchangeInstallerPath\setup.exe"
			Arguments = "/Mode:Install /Role:Mailbox /OrganizationName:ExchOrg /TargetDir:F:\Exchange /IAcceptExchangeServerLicenseTerms"
			Credential = $DomainCreds
            DependsOn = '[xPendingReboot]RebootPostInstallUCMA4'
			PsDscRunAsCredential = $DomainCreds
        }
		LocalConfigurationManager 
        {
			ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $True
        }
	}
}
