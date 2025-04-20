function Get-ADUserInfo {
    # Vérifier que le module ActiveDirectory est disponible
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        [System.Windows.Forms.MessageBox]::Show("Le module Active Directory n'est pas installé.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Importer le module Active Directory
    Import-Module ActiveDirectory

    # Récupérer les utilisateurs et leurs informations
    $users = Get-ADUser -Filter * -Property DisplayName, EmailAddress, PasswordLastSet, PasswordNeverExpires | Where-Object {
        $_.EmailAddress -ne $null -and $_.PasswordNeverExpires -eq $true
    }

    # Récupérer la politique de mot de passe du domaine
    $passwordPolicy = Get-ADDefaultDomainPasswordPolicy

    # Créer une liste personnalisée d'objets avec les informations des utilisateurs
    $userList = foreach ($user in $users) {
        $expirationDate = "Jamais défini"  # Valeur par défaut si aucune date d'expiration

        if ($user.PasswordLastSet) {
            try {
                # Calcul de la date d'expiration en ajoutant le nombre de jours de MaxPasswordAge à PasswordLastSet
                $maxAge = $passwordPolicy.MaxPasswordAge.Days
                $expirationDate = ($user.PasswordLastSet).AddDays($maxAge)

                # Si la date d'expiration est dans le futur, afficher cette date ; sinon, afficher "Mot de passe expiré"
                if ($expirationDate -lt (Get-Date)) {
                    $expirationDate = "Mot de passe expiré"
                }
            } catch {
                $expirationDate = "Erreur de calcul"
            }
        }

        # Créer un objet personnalisé avec les informations à afficher
        [PSCustomObject]@{
            Name = $user.DisplayName
            Email = $user.EmailAddress
            PasswordExpirationDate = $expirationDate
        }
    }

    return $userList
}