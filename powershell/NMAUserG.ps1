<#
.SYNOPSIS
    - The following function will take a csv formatted with columns named: Project Assignment,Status,Staff person,Work Email Address
    - The function will use the Work Email Address column to go through each entry
    - If a blank entry is found it will be skipped.
    - If the column contains an email NOT like @nanmckay.com it will be skipped.
.Prerequisites
    You must run this script on a PowerShell Version 5.1 or higher and have the latest MSOLService module installed. 
    --> Install-Module -Name MSOnline -Force
    --> Source: https://www.powershellgallery.com/packages/MSOnline/1.1.183.66

.EXAMPLE RUN
    1. Load the function into powershell with: . .\Add-NMAUsrToGroup.ps1
    2. Add users' email in the full_list_upn.csv into a security group named Something use the following syntax:
    --> Add-NMAUserToGroup -SourceCSVPath full_list_upn.csv -GroupName Something
.NOTES
    Filename: Add-NMAUsrToGroup.ps1
    Author: GemTeam
    Version 1
#>
function Add-NMAUserToGroup  {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][String]$SourceCSVPath,
        [Parameter(Mandatory=$true)][String]$GroupName,
        [Parameter(Mandatory=$false)][ValidateSet('AD','AAD','365')][String]$GroupType
    )

    #Establish connectivity with TLS 1.2 / 365
    $TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol
    #Establish a connection to o365 as admin running the script, this can be done automatically in a pipeline with secrets management.
    Connect-MsolService
    $NameCSV = Import-Csv -Path $SourceCSVPath

    foreach ($name in $NameCSV){
        if ($name."Work Email Address" -eq "" -or $null -eq $name."Work Email Address" ) {
            Write-Host "Skipping blank"
            continue
        }
        if ($name."Work Email Address" -like "*@nanmckay.com") {
            $gmsg = "Adding " + $name."Work Email Address" + " to "  + $GroupName
            Write-Host $gmsg -BackgroundColor Black -ForegroundColor Green
            Add-ADGroupMember -Identity $GroupName -members $name."Work Email Address"
        }
        else {
            $name."Work Email Address"
            Write-Host "Cannot process entry since it is not a blank or email doesn't end with @nanmckay.com"
        }
        
    }
}