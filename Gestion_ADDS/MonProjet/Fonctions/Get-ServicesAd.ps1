function Get-ServicesList {
    param(
        [string]$Filter = ""
    )
    Get-Service | Where-Object { $_.DisplayName -like "*$Filter*" } | ForEach-Object {
        [PSCustomObject]@{
            DisplayName = $_.DisplayName
            Status = $_.Status
            StartType = (Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -eq $_.Name }).StartMode
        }
    }
}

function Start-SelectedService {
    param(
        [string]$ServiceName
    )
    $service = Get-Service -DisplayName $ServiceName -ErrorAction SilentlyContinue
    if ($service -and $service.Status -ne 'Running') {
        Start-Service -Name $service.Name
    }
}

function Stop-SelectedService {
    param(
        [string]$ServiceName
    )
    $service = Get-Service -DisplayName $ServiceName -ErrorAction SilentlyContinue
    if ($service -and $service.Status -ne 'Stopped') {
        Stop-Service -Name $service.Name
    }
}
