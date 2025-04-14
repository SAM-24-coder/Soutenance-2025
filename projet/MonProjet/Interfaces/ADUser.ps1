# Importer les types nécessaires pour Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Charger le module des fonctions
. "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Fonctions\ADDuser.ps1"

# Création de la fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Ajouter un Utilisateur dans Active Directory"
$form.Size = New-Object System.Drawing.Size(500, 500)
$form.StartPosition = "CenterScreen"

# Champ : Domaine AD
$labelDomain = New-Object System.Windows.Forms.Label
$labelDomain.Text = "Domaine Active Directory :"
$labelDomain.Location = New-Object System.Drawing.Point(20, 30)
$labelDomain.AutoSize = $true
$form.Controls.Add($labelDomain)

$textBoxDomain = New-Object System.Windows.Forms.TextBox
$textBoxDomain.Location = New-Object System.Drawing.Point(200, 30)
$textBoxDomain.Width = 250
$form.Controls.Add($textBoxDomain)

# Bouton : Charger les OUs
$loadOUsButton = New-Object System.Windows.Forms.Button
$loadOUsButton.Text = "Charger les OUs"
$loadOUsButton.Location = New-Object System.Drawing.Point(200, 70)
$loadOUsButton.Size = New-Object System.Drawing.Size(150, 30)
$form.Controls.Add($loadOUsButton)

# Liste déroulante : Sélectionner l'OU
$labelOU = New-Object System.Windows.Forms.Label
$labelOU.Text = "Sélectionner une OU :"
$labelOU.Location = New-Object System.Drawing.Point(20, 120)
$labelOU.AutoSize = $true
$form.Controls.Add($labelOU)

$comboBoxOU = New-Object System.Windows.Forms.ComboBox
$comboBoxOU.Location = New-Object System.Drawing.Point(200, 120)
$comboBoxOU.Width = 250
$form.Controls.Add($comboBoxOU)

# Champ : Prénom
$labelFirstName = New-Object System.Windows.Forms.Label
$labelFirstName.Text = "Prénom :"
$labelFirstName.Location = New-Object System.Drawing.Point(20, 170)
$labelFirstName.AutoSize = $true
$form.Controls.Add($labelFirstName)

$textBoxFirstName = New-Object System.Windows.Forms.TextBox
$textBoxFirstName.Location = New-Object System.Drawing.Point(200, 170)
$textBoxFirstName.Width = 250
$form.Controls.Add($textBoxFirstName)

# Champ : Nom
$labelLastName = New-Object System.Windows.Forms.Label
$labelLastName.Text = "Nom :"
$labelLastName.Location = New-Object System.Drawing.Point(20, 210)
$labelLastName.AutoSize = $true
$form.Controls.Add($labelLastName)

$textBoxLastName = New-Object System.Windows.Forms.TextBox
$textBoxLastName.Location = New-Object System.Drawing.Point(200, 210)
$textBoxLastName.Width = 250
$form.Controls.Add($textBoxLastName)

# Champ : Email généré automatiquement (lecture seule)
$labelEmail = New-Object System.Windows.Forms.Label
$labelEmail.Text = "Email généré :"
$labelEmail.Location = New-Object System.Drawing.Point(20, 250)
$labelEmail.AutoSize = $true
$form.Controls.Add($labelEmail)

$textBoxEmail = New-Object System.Windows.Forms.TextBox
$textBoxEmail.Location = New-Object System.Drawing.Point(200, 250)
$textBoxEmail.Width = 250
$textBoxEmail.ReadOnly = $true
$form.Controls.Add($textBoxEmail)

# Bouton : Ajouter l'utilisateur
$addButton = New-Object System.Windows.Forms.Button
$addButton.Text = "Ajouter l'utilisateur"
$addButton.Location = New-Object System.Drawing.Point(200, 290)
$addButton.Size = New-Object System.Drawing.Size(150, 30)
$form.Controls.Add($addButton)

# Action : Charger les OUs
$loadOUsButton.Add_Click({
    $comboBoxOU.Items.Clear()
    $domain = $textBoxDomain.Text

    if (-not $domain) {
        [System.Windows.Forms.MessageBox]::Show("Veuillez entrer un domaine.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $OUs = Get-ADOrganizationalUnits -Domain $domain
    foreach ($ou in $OUs) {
        $comboBoxOU.Items.Add($ou)
    }
})

# Action : Mettre à jour l'email automatique
function UpdateEmailField {
    $FirstName = $textBoxFirstName.Text
    $LastName = $textBoxLastName.Text
    $Domain = $textBoxDomain.Text

    if ($FirstName -and $LastName -and $Domain) {
        $textBoxEmail.Text = "$FirstName.$LastName@$Domain".ToLower()
    } else {
        $textBoxEmail.Text = ""
    }
}

$textBoxFirstName.Add_TextChanged({ UpdateEmailField })
$textBoxLastName.Add_TextChanged({ UpdateEmailField })
$textBoxDomain.Add_TextChanged({ UpdateEmailField })

# Action : Ajouter l'utilisateur
$addButton.Add_Click({
    Add-ADUser -FirstName $textBoxFirstName.Text -LastName $textBoxLastName.Text -Domain $textBoxDomain.Text -OU $comboBoxOU.SelectedItem
})

# Afficher la fenêtre
$form.ShowDialog()
