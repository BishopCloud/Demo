

$LogfileName = "Defender-Detection"
$service = "windefend"
$AcceptableVersions = @('4.18.2101.4','4.18.2101.8','4.18.2101.9')


#region computedvariables

$Logfile = "$env:SystemRoot\logs\$LogfileName.log"

#endregion computedvariables

#region functions

Function Write-Log
{
	Param ([string]$logstring)
	If (Test-Path $Logfile)
	{
		If ((Get-Item $Logfile).Length -gt 2MB)
		{
			Rename-Item $Logfile $Logfile".bak" -Force
		}
	}
	$WriteLine = (Get-Date).ToString() + " " + $logstring
	Add-content $Logfile -value $WriteLine
}

#endregion functions

#region main

Write-Log ""
Write-Log "<<<<<<----------Starting Script Execution---------->>>>>>"


$ServiceInfo = Get-WmiObject win32_service | ?{$_.Name -like $service} | select Name, DisplayName, State, PathName #Query WMI for the service name defined in the $service variable.
if($($ServiceInfo.PathName -replace '"','') -gt "")
    {
        $FileToVerify = $($ServiceInfo.PathName -replace '"','') #Returns the full path to the service executable.
        Write-Log "Found Service Exe from WMI: $FileToVerify"
    }
Else
    {
        $FileToVerify = "C:\x.x"
        Write-Log "Service path not found!"
    }


If(Test-Path $FileToVerify)  #Check to see if the exe exists on the file system.
{
	Write-Log "Found Service File"
	$FileInfo = Get-Item $FileToVerify  #Gets the file properties
	Write-Log "Get File Details"
	Write-Log $("Service Version found: " + $FileInfo.VersionInfo.ProductVersion)

    if($FileInfo.VersionInfo.ProductVersion -in $AcceptableVersions) #Checks to see if the product version of the file in in the $AcceptableVersions list.
        {
            Write-Log $("Success: Found acceptable installed version " + $FileInfo.VersionInfo.ProductVersion + " is contained in acceptable version list: " + $($AcceptableVersions -join ","))
            Write-Log "<<<<<<----------Script Exectuion End!---------->>>>>>"
            Write-Log ""
            Return $true
        }
    else
        {
            Write-Log $("***** ERROR: version " + $FileInfo.VersionInfo.ProductVersion + " is NOT contained in acceptable version list: " + $($AcceptableVersions -join ",") + " *****")
        }
}
Else
{
	Write-Log "Warning: File to verify not found!"
}

Write-Log "<<<<<<----------Script Exectuion End!---------->>>>>>"

#endregion
