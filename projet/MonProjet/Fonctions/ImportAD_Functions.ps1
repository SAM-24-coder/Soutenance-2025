function Import-UsersToAD {
    param (
        [Parameter(Mandatory=$true)] [Array]$CSVData,
        [Parameter(Mandatory=$true)] [System.Windows.Forms.TextBox]$LogsBox
    )

    Foreach ($Utilisateur in $CSVData) {
        $UtilisateurPrenom = $Utilisateur.Prenom
        $UtilisateurNom = $Utilisateur.Nom
        $UtilisateurLogin = ($UtilisateurPrenom).Substring(0,1) + "." + $UtilisateurNom
        $UtilisateurEmail = "$UtilisateurLogin@localhost.local"
        $UtilisateurMotDePasse = "LocalHost@2024"  # Peut être modifié

        # Vérifier si l'utilisateur existe déjà dans AD
        if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin} -ErrorAction SilentlyContinue) {
            $LogsBox.AppendText("⚠️ $UtilisateurLogin existe déjà dans AD.`r`n")
        }
        else {
            try {
                # Création de l'utilisateur
                New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                           -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
                           -GivenName $UtilisateurPrenom `
                           -Surname $UtilisateurNom `
                           -SamAccountName $UtilisateurLogin `
                           -UserPrincipalName "$UtilisateurLogin@localhost.local" `
                           -EmailAddress $UtilisateurEmail `
                           -Path "OU=OU_AIS,DC=localhost,DC=local" `
                           -AccountPassword (ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                           -ChangePasswordAtLogon $true `
                           -Enabled $true

                $LogsBox.AppendText("✅ Utilisateur ajouté : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)`r`n")
            }
            catch {
                $LogsBox.AppendText("❌ Erreur lors de la création de $UtilisateurLogin : $_`r`n")
            }
        }
    }
}
