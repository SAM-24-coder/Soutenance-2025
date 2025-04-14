. "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Fonctions\UserFunctions.ps1"
. "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Fonctions\ReportFunctions.ps1"
. "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\MainForm.ps1"
. "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\SettingsForm.ps1"

function Show-Main {
     $form = New-Object System.Windows.Forms.Form
    $form.Text = "Gestion des Utilisateurs AD"
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.BackColor = [System.Drawing.Color]::White

    # Titre du formulaire
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "Tableau de Bord de Gestion des Utilisateurs"
    $titleLabel.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $titleLabel.Location = New-Object System.Drawing.Point(200, 20)
    $titleLabel.AutoSize = $true
    $form.Controls.Add($titleLabel)

    # Boutons
    $buttonWidth = 180
    $buttonHeight = 50
    $buttonMargin = 10

    # Suivi des comptes
    $accountsButton = New-Object System.Windows.Forms.Button
    $accountsButton.Text = "Suivi des Comptes"
    $accountsButton.Location = New-Object System.Drawing.Point(50, 100)
    $accountsButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $accountsButton.BackColor = [System.Drawing.Color]::LightBlue
    $accountsButton.Add_Click({
   # . "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Interfaces\MainForm.ps1"
   Show-MainForm
    })
    $form.Controls.Add($accountsButton)

    # Vérifier la date de dernière connexion
    $lastLogonButton = New-Object System.Windows.Forms.Button
    $lastLogonButton.Text = "Vérifier Dernière Connexion"
    $lastLogonButton.Location = New-Object System.Drawing.Point(300, 100)
    $lastLogonButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $lastLogonButton.BackColor = [System.Drawing.Color]::LightGreen
    $lastLogonButton.Add_Click({
    . "C:\Users\Administrateur\Desktop\Gestion_ADDS\iteration1\main.ps1"
    })
    $form.Controls.Add($lastLogonButton)

    # Paramètres
    $settingsButton = New-Object System.Windows.Forms.Button
    $settingsButton.Text = "Paramètres"
    $settingsButton.Location = New-Object System.Drawing.Point(550, 100)
    $settingsButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $settingsButton.BackColor = [System.Drawing.Color]::LightCoral
    $settingsButton.Add_Click({
        # Logique pour les paramètres
        [System.Windows.Forms.MessageBox]::Show("Fonctionnalité des paramètres à implémenter.", "Information")
    })
    $form.Controls.Add($settingsButton)

    # Créer des groupes
    $createGroupButton = New-Object System.Windows.Forms.Button
    $createGroupButton.Text = "Créer des Groupes"
    $createGroupButton.Location = New-Object System.Drawing.Point(300, 200)
    $createGroupButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $createGroupButton.BackColor = [System.Drawing.Color]::LightYellow
    $createGroupButton.Add_Click({
        # Logique pour créer des groupes
        [System.Windows.Forms.MessageBox]::Show("Fonctionnalité de création de groupes à implémenter.", "Information")
    })
    $form.Controls.Add($createGroupButton)

    # Afficher le formulaire
    $form.Add_Shown({$form.Activate()})
    [void]$form.ShowDialog()
}
Show-Main