# Importer le module Active Directory
Import-Module ActiveDirectory

# Fonction pour récupérer les OUs d'un domaine Active Directory
function Get-ADOrganizationalUnits {
    param (
        [string]$Domain
    )
    try {
        return Get-ADOrganizationalUnit -Filter * -Server $Domain | Select-Object -ExpandProperty DistinguishedName
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Impossible de récupérer les OUs : $_", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return @()
    }
}

# Fonction pour ajouter un utilisateur dans Active Directory
function Add-ADUser {
    param (
        [string]$FirstName,
        [string]$LastName,
        [string]$Domain,
        [string]$OU
    )

    try {
        # Générer l'email automatique
        $Email = "$FirstName.$LastName@$Domain".ToLower()

        # Générer le SamAccountName (Première lettre du prénom + Nom en minuscules)
        $SamAccountName = "$($FirstName.Substring(0, 1).ToLower())$($LastName.ToLower())"

        # Définir les paramètres utilisateur
        $userParams = @{
            Name                     = "$FirstName $LastName"
            GivenName                = $FirstName
            Surname                  = $LastName
            EmailAddress             = $Email
            UserPrincipalName        = $Email
            SamAccountName           = $SamAccountName
            DisplayName              = "$FirstName $LastName"
            Enabled                  = $true
            Path                     = $OU
            ChangePasswordAtLogon    = $true
            PasswordNeverExpires     = $false
        }

        # Mot de passe par défaut
        $Password = ConvertTo-SecureString "Az3rty@2024" -AsPlainText -Force

        # Vérifier si l'utilisateur existe déjà
        if (Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -ErrorAction SilentlyContinue) {
            [System.Windows.Forms.MessageBox]::Show("L'utilisateur $SamAccountName existe déjà.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        # Création de l'utilisateur avec mot de passe
        New-ADUser @userParams -AccountPassword $Password

        [System.Windows.Forms.MessageBox]::Show("Utilisateur $FirstName $LastName ajouté avec succès !", "Succès", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur lors de la création de l'utilisateur : $_", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}
