Import-Module ActiveDirectory

function Get-ADUserLastLogon {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Get-ADUser $_})]
        $Identity
    )

    # Récupérer la liste de tous les contrôleurs de domaine (DC)
    $DCList = Get-ADDomainController -Filter * | Sort-Object Name | Select-Object -ExpandProperty Name
    $LatestLogon = $null

    foreach ($DC in $DCList) {
        try {
            # Récupérer l'attribut LastLogon depuis chaque DC
            $User = Get-ADUser -Identity $Identity -Properties lastLogon -Server $DC
            $LogonTime = [DateTime]::FromFileTime($User.LastLogon)

            # Garder la date la plus récente
            if ($LogonTime -gt $LatestLogon) {
                $LatestLogon = $LogonTime
            }
        } catch {
            Write-Host "Erreur sur $DC : $_" -ForegroundColor Red
        }
    }

    return $LatestLogon
}
