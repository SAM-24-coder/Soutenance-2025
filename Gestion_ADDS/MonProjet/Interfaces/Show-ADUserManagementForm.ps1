Import-Module ActiveDirectory

# Importer les fonctions AD depuis un fichier séparé
. "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Fonctions\Get-ADUserLastLogon.ps1"

function Show-ADUserManagementForm {
    # Fonction pour récupérer la dernière connexion d'un utilisateur
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

    # GUI principale
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Application de Gestion des Utilisateurs"
    $form.Size = New-Object System.Drawing.Size(1000, 600)
    $form.StartPosition = "CenterScreen"

    # ListView pour afficher les utilisateurs
    $listView = New-Object System.Windows.Forms.ListView
    $listView.Size = New-Object System.Drawing.Size(600, 400)
    $listView.Location = New-Object System.Drawing.Point(20, 60)
    $listView.View = [System.Windows.Forms.View]::Details
    $listView.Columns.Add("Nom", 200)
    $listView.Columns.Add("Email", 250)
    $form.Controls.Add($listView)

    # Charger les utilisateurs dans le ListView
    $loadButton = New-Object System.Windows.Forms.Button
    $loadButton.Text = "Charger les utilisateurs"
    $loadButton.Size = New-Object System.Drawing.Size(150, 30)
    $loadButton.Location = New-Object System.Drawing.Point(20, 480)
    $form.Controls.Add($loadButton)

    # Panel pour vérifier le LastLogon
    $lastLogonPanel = New-Object System.Windows.Forms.Panel
    $lastLogonPanel.Size = New-Object System.Drawing.Size(300, 400)
    $lastLogonPanel.Location = New-Object System.Drawing.Point(640, 60)
    $lastLogonPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $form.Controls.Add($lastLogonPanel)

    $LabelSelectUser = New-Object System.Windows.Forms.Label
    $LabelSelectUser.Text = "Sélectionner un utilisateur :"
    $LabelSelectUser.Location = New-Object System.Drawing.Point(10, 20)
    $LabelSelectUser.AutoSize = $true
    $lastLogonPanel.Controls.Add($LabelSelectUser)

    $ComboBoxUserList = New-Object System.Windows.Forms.ComboBox
    $ComboBoxUserList.Width = 250
    $ComboBoxUserList.Location = New-Object System.Drawing.Point(10, 50)
    $lastLogonPanel.Controls.Add($ComboBoxUserList)

    $ButtonCheck = New-Object System.Windows.Forms.Button
    $ButtonCheck.Text = "Vérifier"
    $ButtonCheck.Size = New-Object System.Drawing.Size(100, 30)
    $ButtonCheck.Location = New-Object System.Drawing.Point(10, 100)
    $lastLogonPanel.Controls.Add($ButtonCheck)

    $LastLogonLabel = New-Object System.Windows.Forms.Label
    $LastLogonLabel.Text = "Dernière connexion :"
    $LastLogonLabel.Location = New-Object System.Drawing.Point(10, 150)
    $LastLogonLabel.AutoSize = $true
    $LastLogonLabel.ForeColor = "green"
    $lastLogonPanel.Controls.Add($LastLogonLabel)

    # Action : Charger les utilisateurs
    $loadButton.Add_Click({
        $listView.SuspendLayout()
        $listView.Items.Clear()

        try {
            $users = Get-ADUser -Filter * -Property DisplayName, EmailAddress | Where-Object {
                $_.EmailAddress -ne $null
            }

            foreach ($user in $users) {
                $item = New-Object System.Windows.Forms.ListViewItem($user.DisplayName)
                $item.SubItems.Add($user.EmailAddress)
                $passwordExpiration = if ($user.PasswordLastSet) {
                    ($user.PasswordLastSet).AddDays((Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days)
                } else {
                    "Jamais défini"
                }
                $item.SubItems.Add($passwordExpiration)
                $listView.Items.Add($item)

                $ComboBoxUserList.Items.Add($user.DisplayName)
            }

            if ($users.Count -eq 0) {
                [System.Windows.Forms.MessageBox]::Show("Aucun utilisateur trouvé.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Erreur : $_", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }

        $listView.ResumeLayout()
    })

    # Action : Vérifier le LastLogon
    $ButtonCheck.Add_Click({
        if ($ComboBoxUserList.SelectedItem -ne $null) {
            $selectedUser = $ComboBoxUserList.SelectedItem
            $lastLogon = Get-ADUserLastLogon -Identity $selectedUser

            if ($lastLogon) {
                $LastLogonLabel.Text = "Dernière connexion de $selectedUser : $lastLogon"
            } else {
                $LastLogonLabel.Text = "Aucune connexion enregistrée pour $selectedUser."
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Vous devez sélectionner un utilisateur !", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    # Affichage de la fenêtre
    $form.ShowDialog()
}
Show-ADUserManagementForm
 
