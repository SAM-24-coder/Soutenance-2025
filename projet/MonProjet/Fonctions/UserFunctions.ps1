# /Fonctions/UserFunctions.ps1

function Get-ADUsers {
    Import-Module ActiveDirectory
    $users = Get-ADUser -Filter * -Properties SamAccountName, Enabled | Select-Object Name, SamAccountName, Enabled
    return $users
}

function Get-UserAccounts {
    # Logique pour obtenir les comptes utilisateurs
    # Remplace par la logique Active Directory si nÃ©cessaire
    return @(
        @{ Username = "User1"; Status = "Actif"; Expiration = "2025-01-01" },
        @{ Username = "User2"; Status = "Bloqué"; Expiration = "2025-01-01" }
    )
}

function Reset-UserPassword {
    param (
        [string]$username
    )
    # Logique pour rÃ©initialiser le mot de passe
    Write-Host "RÃ©initialisation du mot de passe pour $username"
}

function Unlock-UserAccount {
    param (
        [string]$username
    )
    # Logique pour dÃ©bloquer le compte
    Write-Host "DÃ©blocage du compte pour $username"
}
function Show-InputBox {
    param (
        [string]$message = "Entrez une valeur :",
        [string]$title = "Boîte de dialogue"
    )

    Add-Type -AssemblyName Microsoft.VisualBasic
    $input = [Microsoft.VisualBasic.Interaction]::InputBox($message, $title, "")
    return $input
}


