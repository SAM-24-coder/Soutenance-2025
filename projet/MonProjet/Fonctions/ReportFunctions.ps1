# Fonctions/ReportFunctions.ps1

function Generate-UserReport {
    param (
        [string]$filePath
    )
    
    $reportData = @(
        @{ Username = "User1"; Status = "Actif"; Expiration = "2025-01-01" },
        @{ Username = "User2"; Status = "BloquÃ©"; Expiration = "2025-01-01" }
        @{ Username = "User3"; Status = "Bloqué"; Expiration = "2024-12-10" }
        @{ Username = "User2"; Status = "Actif"; Expiration = "2025-11-01" }
        @{ Username = "User2"; Status = "Bloqué"; Expiration = "2024-11-01" }

    )

    # Convertir les donnÃ©es en format CSV
    $reportData | Export-Csv -Path $filePath -NoTypeInformation
    Write-Host "Rapport généré Ã  : $filePath"
}

function Get-ReportData {
    return @(
        @{ Username = "User1"; Status = "Actif"; Expiration = "2025-01-01" },
        @{ Username = "User2"; Status = "BloquÃ©"; Expiration = "2025-01-01" }
        @{ Username = "User3"; Status = "Bloqué"; Expiration = "2024-12-10" }
        @{ Username = "User2"; Status = "Actif"; Expiration = "2025-11-01" }
        @{ Username = "User2"; Status = "Bloqué"; Expiration = "2024-11-01" }

    )
}