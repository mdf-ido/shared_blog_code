<#
.SYNOPSIS
    - The following function uses the Azure Vault stored credentials to login to Bitwarden and retrieve a password.

.Prerequisites
    1. Install the bitwarden CLI: choco install bitwarden-cli 
    2. You must have the Powershell Vault Configured
    3. You must set the Powershell Secrets ahead of time in the Powershell Vault

.EXAMPLE RUN
    1. Load the function into powershell with: . .\Bitwarden.ps1
    2. To run the script use the following syntax: Get-BWSecret -BWSecretName Test1 -SaveinPWVault $true -PWVaultSecretName Test3 
    

.NOTES
    Filename: Bitwarden.ps1
    Author: Mo Figueroa 
    Soundtrack: The Killers - Pressure Machine
#>
function Get-BWSecret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][String]$BWSecretName,
        [Parameter(Mandatory=$false)][bool]$SaveinPWVault,
        [Parameter(Mandatory=$false)][String]$PWVaultSecretName
    )
    $env:BW_CLIENTID = Get-Secret -Vault ICSecrets -Name BWAPIClient -AsPlainText
    $env:BW_CLIENTSECRET = Get-Secret -Vault ICSecrets -Name BWAPIClientSec -AsPlainText
    $env:BW_PASSWORD = Get-Secret -Vault ICSecrets -Name BWPass -AsPlainText
    #BW
    [void](Invoke-Command -ScriptBlock {bw login --apikey})
    $unlockSesh = Invoke-Command -ScriptBlock {bw unlock --passwordenv BW_PASSWORD}
    $pwline = $unlockSesh | Select -Last 4 | Select -First 1
    $seshkey = $pwline.Split('"')[1] 
    $bwtopwsecret = Invoke-Command -ScriptBlock {bw get password "$BWSecretName" --session $seshkey} 
    if ($SaveinPWVault -eq $true){
        Set-Secret -Name $PWVaultSecretName -Secret $bwtopwsecret
    }
    else {
        $bwtopwsecret
    }
    [void](Invoke-Command -ScriptBlock {bw logout})
    #Null ENVs
    $env:BW_CLIENTID = ""
    $env:BW_CLIENTSECRET = ""
    $env:BW_PASSWORD = ""
}
