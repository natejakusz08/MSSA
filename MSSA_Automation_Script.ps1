  $continue = $true
while ($continue) {
    #Write-Host "'n'n'n" # adds three blank lines
    Write-Host "                                                                     "
    Write-Host "====================================================================="
    Write-Host "     Microsoft Software and Systems Academy Carpe-Schema Menu        "
    Write-Host "====================================================================="
    Write-Host "                                  "
    Write-Host "1. Disable an AD user account    "
    Write-Host "                                  "
    Write-Host "2. Enable an AD user account "
    Write-Host "                                  "
    Write-Host "3. Check for locked AD user accounts "
    Write-Host "                                  "
    Write-Host "4. Unlock an AD user account "
    Write-Host "                                  "
    Write-Host "5. Reset AD user account password "
    Write-Host "                                  "
    Write-Host "6. Identify accounts without logins >90 days "
    Write-Host "                                  "
    Write-Host "7. Disable accounts without logins >90 days "
    Write-Host "   "
    Write-Host "8. Add New Organizational Unit (OU)"
    Write-Host "   "  
    Write-Host "9. Force GPUpdate on Domain Computer"
    Write-Host "   "
    Write-Host "10. Create AD user account          "
    Write-Host "                                    "
    Write-Host "11. Move User to New OU"
    Write-Host " "
    Write-Host "12. Create Batch Users From CSV"
    Write-Host "   "
    Write-Host "13. Disable Stale Computers (>90 days) and Move to Stale OU"
    Write-Host "   "
    Write-Host "X. Exit this menu                 "
    Write-Host "                                  "
    $choice = Read-Host  "Enter selection"
    switch ($choice) {
        "1" {
	        If ($termuser -eq "")
	        { $termuser = (Read-Host "Enter username")
	        }
	        $termuser = Read-Host "Enter username:"
	        $fullname = (Get-Aduser -Identity $termuser).Name
	        $Answer = Read-Host "$fullname will be disabled. Is this the information you want to use (y/N)"
	        If ($Answer.ToUpper() -ne "Y")
	        { Write-Host "`n`nOK.  Please rerun the script and reenter the data correctly.`n"
	        Break
	        }
	        Write-Output "Disabling account for $termuser"
	        Disable-ADAccount -Identity $termuser          
                 }
        "2" {
	        If ($ENuser -eq "")
	        { $ENuser = (Read-Host "Enter username")
	        }
	        $ENuser = Read-Host "Enter username"
	        $fullname = (Get-Aduser -Identity $ENuser).Name
	        $Answer = Read-Host "$fullname will be enabled. Is this the information you want to use (y/N)"
	        If ($Answer.ToUpper() -ne "Y")
	        { Write-Host "`n`nOK.  Please rerun the script and reenter the data correctly.`n"
	        Break
	        }
	        Write-Output "Enable account for $ENuser"
	        Enable-ADAccount -Identity $ENuser
                }
        "3" {        
	        Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, Userprincipalname | Out-GridView
                }
        "4" {    
	        If ($unlockuser -eq "")
	        { $unlockuser = (Read-Host "Enter username")
	        }
	        $unlockuser = Read-Host "Enter username:"
	        $fullname = (Get-Aduser -Identity $unlockuser).Name
	        $Answer = Read-Host "Do you want to unlock the account for $fullname ? (y/N)"
	        If ($Answer.ToUpper() -ne "Y")
	        { Write-Host "`n`nOK.  Please rerun the script and reenter the data correctly.`n"
	        Break
	        }
	        Write-Output "Unlocking the account for $unlockuser"
	        Unlock-ADAccount -Identity $unlockuser
                }
        "5" {
	        If ($Passuser -eq "")
	        { $Passuser = (Read-Host "Enter username")
	        }
	        $Passuser = Read-Host "Enter username"
	        $fullname = (Get-Aduser -Identity $Passuser).Name
	        $Answer = Read-Host "Reset $fullname password? (y/N)"
	        If ($Answer.ToUpper() -ne "Y")
	        { Write-Host "`n`nOK.  Please rerun the script and reenter the data correctly.`n"
	        Break
	        }
	        $password = Read-Host "Enter password"
	        Write-Output "Resetting password for $Passuser"
	        Set-ADAccountPassword -Identity $Passuser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Password" -Force)
                }
        "6" {
	        Write-Output "Currently exporting to c:unusedaccounts.csv"       
	        Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 | ?{$_.enabled -eq $true} | %{Get-ADUser $_.ObjectGuid} | select name, givenname, surname, Userprincipalname  | export-csv c:unusedaccounts.csv -NoTypeInformation
	        Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 | ?{$_.enabled -eq $true} | %{Get-ADUser $_.ObjectGuid} | select name, givenname, surname, Userprincipalname  | out-gridview
                }
        "7" {
	    $OU1 = Read-Host "Enter Name of Stale Account OU"
            $DC1 = Read-Host "Enter Name of Organization Domain"
            $DC2 = Read-Host "Enter Name of Public Domain"
        
            $TargetOU =  "ou=$OU1,dc=$DC1,dc=$DC2"
            
		
		Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 | ?{$_.enabled -eq $true} |  Move-ADObject  -TargetPath $TargetOU
		Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 | ?{$_.enabled -eq $true} |  Disable-ADAccount
                }
        "8" {
                $nested = Read-Host "Is OU nested? (y/N)"
                If ($nested -eq "y")
                {
                function CreateOU {
                Param([string]$Name1, [string]$Name2, [string]$Name3)}
                $Name1 = Read-host “enter proposed OU Name (Example = 'IT')”
                $name4 = Read-host “enter base layer OU (Example = 'Adatum Chicago')”
                $Name2 = Read-host "enter Domain Name (Example = 'Adatum')"
                $Name3 = Read-host "enter Domain Extension (Example = 'com')"
                #Format variables into valid Distinguished Name.
                $DistinguishedName = "OU=$Name1,dc=$Name2,dc=$Name3"
                #Check to see if OU already exists.
                try {
                Get-ADOrganizationalUnit -Identity $DistinguishedName | Out-Null
                Write-Host "CreateOU - OU Already Existed: $DistinguishedName"
                }
                #Create OU if does not exist
                catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                Write-Host "CreateOU - Creating new OU: $DistinguishedName"
                New-ADOrganizationalUnit -Name $Name1 -Path "ou=$name4, dc=$Name2,dc=$Name3"
                Write-Host "CreateOU - OU Created: $DistinguishedName"
                } 
                }
                ########################################################################
                Else
                {
                function CreateOU {
                Param([string]$Name1, [string]$Name2, [string]$Name3)}
                $Name1 = Read-host “enter proposed OU Name (Example = 'IT')”
                $Name2 = Read-host "enter Domain Name (Example = 'Adatum')"
                $Name3 = Read-host "enter Domain Extension (Example = 'com')"
                #Format variables into valid Distinguished Name.
                $DistinguishedName = "OU=$Name1,dc=$Name2,dc=$Name3"
                #Check to see if OU already exists.
                try {
                Get-ADOrganizationalUnit -Identity $DistinguishedName | Out-Null
                Write-Host "CreateOU - OU Already Existed: $DistinguishedName"
                }
                #Create OU if does not exist
                catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                Write-Host "CreateOU - Creating new OU: $DistinguishedName"
                New-ADOrganizationalUnit -Name $Name1 -Path "dc=$Name2,dc=$Name3"
                Write-Host "CreateOU - OU Created: $DistinguishedName"
                } 
                } 
                } 
	#Start GPUpdate Script Added by Brent
	"9" {
		function EnterComputerName {
   		 do {
       			Clear-Host
      			$ComputerName = Read-Host "`nEnter computer name"
   		} until ($ComputerName)
    			$ComputerName = $ComputerName.ToUpper()
    		if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
        	$Session = New-PSSession -ComputerName $ComputerName -ErrorAction SilentlyContinue
        	if ($Session) {Update}
        	else {
            		Clear-Host
            		Write-Host "`nError: Could not establish PowerShell session with $ComputerName.`n" -ForegroundColor Red
            		Pause
        	}
    		}
    		else {
        		Clear-Host
        		Write-Host "`nError: $ComputerName is not on the network.`n" -ForegroundColor Red
        		Pause
   		}
		}
		function Update {
    			Clear-Host
    			Invoke-Command -Session $Session -ScriptBlock {gpupdate.exe /force /wait:0}
    			Remove-PSSession -Session $Session
		}
		if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
			{ Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
			Clear-Host
			Write-Output "`nThis will perform a gpupdate /force on a remote computer.`n"
			Pause
			EnterComputerName 
		}

#End GPUpdate script added by Brent
		"10" {   #Start of Josh code
			#Request users first name        
			$userF = Read-Host "Enter the user First name please"

			#Request users last name
			$userL = Read-Host "Enter the user Last name please"

			#Organizational Unit the user will be place in
			$SelectedOU = Read-Host "Please provide an OU" 

			#Combines users first and last name
			$CN = $userF + " " + $userL

			#Takes the first initial of user first name adds a period and user last name (example: F.Lastname)
			$SamN = $userF.Substring(0,1)+$userL

			#Retrieves the current domain name
			$DomainN = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select-Object Domain

			#Takes the first initial of the user first name and the user last to user principle name (example: F.Lastname@domain.com)
			$upn = $userF.Substring(0,1)+""+$userL+"@"+$DomainN.Domain

			#Default location for user
			$L1 = "OU="+$SelectedOU+",DC=Adatum,DC=com"
      
      #Creates a date 90 days from account creation
      $Cdate = ((Get-Date).Date + "90")
      $DName = Get-ADDomainController -Filter * | Select-Object -ExpandProperty Name

			#Ask user to input a password 
			$PwReq = Write-Host "                                            "
               Write-Host "Password must meet the following requirement:" -ForegroundColor Yellow
               Write-Host "1. password must be at least 8 characters in length" -ForegroundColor Yellow
               Write-Host "2. three of the four characters need to be uppercase, lowercase,numbers, or symbols 'n" -ForegroundColor Yellow 
               Write-Host "3. Does not contain the user’s username" -ForegroundColor Yellow
               Write-Host "                   "
               Write-Host "                   "
               Read-Host -AsSecureString "Please provide a valid password" 
					 
				Try {
				New-ADUser -Name $CN -GivenName $userF -Surname $userL -SamAccountName $SamN -UserPrincipalName $upn -Path $L1 -AccountPassword $PwReq
        Set-ADAccountExpiration -Server $DName -DateTime $Cdate -Identity $SamN
				} catch {
					  Write-Host "The user $CN already exist in '$DomainN.Domain' domain"
				  }
		} #End of Josh Code         
    "11"{
	function ReassignUserOU {
    Param([string]$Name1, [string]$Name2,[string]$Name3,[string]$Name4) }
$Name1 = Read-host “enter Username”
$Name2 = Read-host "enter new OU Name (i.e. IT)"
$Name3 = Read-Host "enter DOmain (i.e. Adatum)"
$Name4 = Read-Host "enter Domain extension (i.e. com)"
 #Check to see if user OU and extension exists.
try {
$user = Get-ADuser "$Name1" 
$user | Move-ADObject -TargetPath "OU=$Name2,dc=$Name3,dc=$Name4" -erroraction stop
Write-Host "User moved to OU: $Name2" -ForegroundColor Green
}
Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
Write-Host "$Name1 can not be found" -ForegroundColor Red                                                      
}
Catch [System.Management.Automation.RuntimeException] { 
Write-Host "OU $Name2\$Name3.$Name4 can not be found" -ForegroundColor Red 
}
          Write-Host "$Name1 can not be found " -ForegroundColor Red
              }
	#End GPUpdate script added by Brent
  "12" {
	#Establishes Variable Baseline For Batch User Creation
		$Drive = Read-host "Input Drive letter of CSV (Exmaple J:)"
		$FilePath = Read-Host "Input File Path of CSV (Example Windows\Users\Bob\Desktop\BatchUsers.csv)"
		$DC1 = Read-Host "Input Organization Domain (Example Adatum)"
		$DC2 = Read-Host "Input Public Domain (Example com / eu / au)"
		$TarPath = $Drive+"\"+$FilePath

#Pulls Data from CSV & Creates Users
		$UserAccounts = Import-CSV -Path $TarPath

		Foreach ($user in $UserAccounts)
        {
    
 		$DisplayName = $user.FirstName+" "+$user.LastName
 		$UserFirstname = $user.FirstName
 		$UserLastname = $user.LastName
 		$SAM = $user.SamAccountName
 		$UPN = $user.UPN
 		$Department = $user.Department
 		$Password = $user.Password
 		$TarOU = "ou=$Department,dc=$DC1,dc=$DC2"

		New-ADUser `
		-Name $DisplayName `
		-Enabled $False `
		-GivenName $UserFirstname `
		-Surname $UserLastname `
		-AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force)`
		-ChangePasswordAtLogon $True `
		-SamAccountName $SAM `
		-UserPrincipalName $UPN `
		-Department $Department `
		-Path $TarOU
        }
		}
	#Start Remove Stale Computers
	"13" {
		#Specify the OU you want to search for inactive accounts 
 
		$SourceOU="OU=Computers,DC=Adatum,DC=com"
 
		#Specify the OU you want to move your inactive computer accounts to 
 
		$DestinationOU="OU=DisabledComputers,DC=Adatum,DC=com" 
 
		#Specify the number of days that computers have been inactive for. The 90 is the number of days from today since the last logon. 
 
		$lldate = [DateTime]::Today.AddDays(-90);
          
		#DO NOT MODIFY BELOW THIS LINE 
 
		$computers=Get-ADComputer -Filter ‘PasswordLastSet -le $lldate’ -Searchbase $SourceOU 
 
		foreach ($computer in $computers){
			$desc="Contact Support, disabled on $(Get-Date) - $($computer.Description)"
			Set-ADComputer $Computer -Description $desc -Enabled $false
			Move-ADObject $computer -TargetPath $destinationOU 
			Add-Content C:\computers.txt -Value "Found $computer, Moved and disabled"
			}
		}
	#End Remove Stale Computers
     "X" {
	        $continue = $false
	        }
                default {
                Write-Host "'n'n ** Unknown Selection **" -ForegroundColor red -BackgroundColor white
        }
    }
}
