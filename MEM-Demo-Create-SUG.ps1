#region connection
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '1/19/2021 8:38:57 AM'.

# Uncomment the line below if running in an environment where script signing is 
# required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "EM1" # Site code 
$ProviderMachineName = "FMM31597MEM001.backyard.corp" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

#endregion
















#region DemoFull
cls
$NewSUGName = "2021-JANUARY-NEEDED"
$DatePostedMin = "1/12/2021"  #When not specifiing the time in the datetime object it defaults to 12:00 AM.
$DatePostedMax = '1/13/2021'  #When not specifiing the time in the datetime object it defaults to 12:00 AM.

# We are filtering the update list based on the Date/Time range provided above.  Also filtering out superseded and expired updates plus including only updates that are showing to have systems needing them in our environment.
$Updates = Get-CMSoftwareUpdate -Fast -DateRevisedMin $DatePostedMin -DateRevisedMax $DatePostedMax | where-object {$_.IsSuperseded -eq $False -and $_.IsExpired -eq $False -and $_.NumMissing -gt 0}| select BulletinID,CI_ID,ISContentProvisioned,Title,LocalizedDisplayName,IsSuperseded,NumMissing


If($Updates.count -lt 1000)
{
    Write-Host ""
    $Updates.localizeddisplayname
    Write-Host ""
    write-host "Found $($Updates.count) updates that match expected criteria." 
    $Answer = Read-Host -Prompt "Do you want to create SUG using the updates listed above? ( Y / N)"
     if($Answer -eq "Y")
        {
            $UG = New-CMSoftwareUpdateGroup -Name $NewSUGName  -UpdateId $Updates.CI_ID 
            Write-Host $("Created SUG: " + $UG.LocalizedDIsplayName + " on " + $UG.DateCreated + " by " + $UG.CreatedBy)

        }
     else
        {
            Write-Host "Exiting without creating SUG"
        }
}
Else
{
    write-host "More than one thousand ($($Updates.count)) , need to further refine the critera."
}



#endregion



<#region DemoSimple

$NewSUGName = "2021-JANUARY-NEEDED"
$DatePostedMin = "1/12/2021"
$DatePostedMax = '1/13/2021'

$Updates = Get-CMSoftwareUpdate -Fast -DateRevisedMin $DatePostedMin -DateRevisedMax $DatePostedMax | where-object {$_.IsSuperseded -eq $False -and $_.IsExpired -eq $False -and $_.NumMissing -gt 0}| select BulletinID,CI_ID,ISContentProvisioned,Title,LocalizedDisplayName,IsSuperseded,NumMissing

$Updates.count

$Updates.localizeddisplayname

New-CMSoftwareUpdateGroup -Name $NewSUGName  -UpdateId $Updates.CI_ID

#endregion

#>
