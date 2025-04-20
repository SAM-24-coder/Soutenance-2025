Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

#."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\MainForm.ps1"
#."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\ADUser.ps1"
#."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\ImportAD_GUI.ps1"
#."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\Show-ADUserManagementForm.ps1"

# Fonction pour récupérer les infos Active Directory
function Get-ADInfo {
    try {
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        $server = $domain.PdcRoleOwner.Name
        $context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('Domain')
        $userPrincipal = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($context, $env:USERNAME)
        $admin = $userPrincipal.SamAccountName

        $searcher = New-Object DirectoryServices.DirectorySearcher([ADSI]"LDAP://$($domain.Name)")
        $searcher.Filter = "(objectClass=user)"
        $userCount = ($searcher.FindAll()).Count

        $searcher.Filter = "(objectClass=organizationalUnit)"
        $ouCount = ($searcher.FindAll()).Count
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur lors de la récupération des informations AD : $_", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return @{Domain='N/A'; Server='N/A'; Users=0; OUs=0; Admin='N/A'}
    }
    return @{Domain=$domain.Name; Server=$server; Users=$userCount; OUs=$ouCount; Admin=$admin}
}

# Création de la fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Page d'Accueil"
$form.Width = 800
$form.Height = 500
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"

# Création de la barre de menu
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$form.Controls.Add($menuStrip)

# Définition des boutons et des sous-menus
$menuItems = @{
    "Audit et surveillance" = @("Dernière connexion", "Modification indésirable", "Enregistrer", "Quitter")
    "Automatisation de la gestion" = @("Ajouter un utilisateur", "Importer des utilisateurs", "Créer un OU", "Add AD Computer")
    "Gestion des comptes" = @("Suivi des comptes", "Dernière connexion", "Réinitialiser", "Options")
    "fonctionnalité et securité" = @("GPO Fond'Ecran", "GPO Config", "GPO AutoLockout", "À propos")
}

# Création des menus
foreach ($menu in $menuItems.Keys) {
    $menuItem = New-Object System.Windows.Forms.ToolStripMenuItem
    $menuItem.Text = $menu

    foreach ($subItem in $menuItems[$menu]) {
        $subMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
        $subMenuItem.Text = $subItem
        $subMenuItem.Add_Click({
        })
        $menuItem.DropDownItems.Add($subMenuItem)
    }
    $menuStrip.Items.Add($menuItem)
}

# Récupération des infos AD
$adInfo = Get-ADInfo

# Affichage des infos AD
$labels = @("Domaine: $($adInfo.Domain)", "Serveur: $($adInfo.Server)", "Utilisateurs: $($adInfo.Users)", "Unités Org.: $($adInfo.OUs)", "Admin: $($adInfo.Admin)")
$yPos = 50
foreach ($text in $labels) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point(20, $yPos)
    $label.AutoSize = $true
    $form.Controls.Add($label)
    $yPos += 30
}

# Création du ListView pour afficher tous les utilisateurs de l'annuaire
$listView = New-Object System.Windows.Forms.ListView
$listView.View = "Details"
$listView.FullRowSelect = $true
$listView.GridLines = $true
$listView.Width = 750
$listView.Height = 200
$listView.Location = New-Object System.Drawing.Point(20, 200)
$listView.Columns.Add("Utilisateur", 200) | Out-Null
$listView.Columns.Add("Nom complet", 250) | Out-Null
$listView.Columns.Add("Email", 250) | Out-Null

# Initialisation du DirectorySearcher
try {
    $searcher = New-Object DirectoryServices.DirectorySearcher([ADSI]"LDAP://$($adInfo.Domain)")
    $searcher.Filter = "(objectClass=user)"
    $searcher.PageSize = 1000
    $results = $searcher.FindAll()

    foreach ($result in $results) {
        if ($result -and $result.GetDirectoryEntry()) {
            $entry = $result.GetDirectoryEntry()
            $samAccountName = $entry.Properties["sAMAccountName"].Value
            $displayName = $entry.Properties["displayName"].Value
            $email = $entry.Properties["mail"].Value

            if ($samAccountName) {
                $item = New-Object System.Windows.Forms.ListViewItem($samAccountName)
                if ($displayName) {
                    $item.SubItems.Add($displayName) | Out-Null
                } else {
                    $item.SubItems.Add("N/A") | Out-Null
                }
                if ($email) {
                    $item.SubItems.Add($email) | Out-Null
                } else {
                    $item.SubItems.Add("N/A") | Out-Null
                }
                $listView.Items.Add($item) | Out-Null
            }
        }
    }
} catch {
    [System.Windows.Forms.MessageBox]::Show("Erreur lors de la récupération des utilisateurs : $_", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}
$form.Controls.Add($listView)

# Fonction pour afficher le formulaire principal de suivi des comptes
function Show-MainForm {
    try {
        # Définir le chemin complet du fichier PowerShell
        $scriptPath = "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\MainForm.ps1"

        if (Test-Path $scriptPath) {
            # Charger et exécuter le script PowerShell pour le suivi des comptes
            . $scriptPath
        } else {
            [System.Windows.Forms.MessageBox]::Show("Le fichier MainForm.ps1 n'a pas été trouvé à l'emplacement spécifié.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur lors du lancement du script : $_", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Gestion de l'option de menu "Suivi des comptes"
$suiviMenuItem = $menuStrip.Items[1].DropDownItems[0]
$suiviMenuItem.Add_Click({
."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\MainForm.ps1"
 Show-MainForm
})

$suiviMenuItem = $menuStrip.Items[0].DropDownItems[0]
$suiviMenuItem.Add_Click({
."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\Show-ADUserManagementForm.ps1"
 # Show-ADUserManagementForm
})

$suiviMenuItem = $menuStrip.Items[3].DropDownItems[0]
$suiviMenuItem.Add_Click({
."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\ADUser.ps1"
 # Show-AddUserForm
})

$suiviMenuItem = $menuStrip.Items[3].DropDownItems[1]
$suiviMenuItem.Add_Click({
."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\ImportAD_GUI.ps1"
 # Show-ImportADForm
})

$suiviMenuItem = $menuStrip.Items[3].DropDownItems[3]
$suiviMenuItem.Add_Click({
."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\Add_Computer.ps1"
 # Show-ImportADForm
})
$suiviMenuItem = $menuStrip.Items[2].DropDownItems[0]
$suiviMenuItem.Add_Click({
."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\GPOFondEcranGUI.ps1"
 # Show-ImportADForm
})

$suiviMenuItem = $menuStrip.Items[2].DropDownItems[1]
$suiviMenuItem.Add_Click({
."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\GPO_Config.ps1"
 # Show-ImportADForm
})

$suiviMenuItem = $menuStrip.Items[2].DropDownItems[2]
$suiviMenuItem.Add_Click({
."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\GPO_AutoLockout.ps1"
 # Show-ImportADForm
})
$suiviMenuItem = $menuStrip.Items[3].DropDownItems[2]
$suiviMenuItem.Add_Click({
."C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\GestionOU_GUI.ps1"
 # Show-ImportADForm
})





# Affichage du formulaire
$form.MainMenuStrip = $menuStrip
$form.ShowDialog()
