# Charger les bibliothèques Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

. "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Fonctions\Gestion_OU_fonction.ps1"


$form = New-Object System.Windows.Forms.Form
$form.Text = "Gestion des Unites d'Organisation (OU)"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"

# Label et ComboBox : OU Parent
$labelOUParent = New-Object System.Windows.Forms.Label
$labelOUParent.Text = "OU Parent :"
$labelOUParent.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($labelOUParent)

$comboBoxOUParent = New-Object System.Windows.Forms.ComboBox
$comboBoxOUParent.Location = New-Object System.Drawing.Point(150, 18)
$comboBoxOUParent.Width = 300
$form.Controls.Add($comboBoxOUParent)

# Label et TextBox : Nom de la nouvelle OU
$labelOUName = New-Object System.Windows.Forms.Label
$labelOUName.Text = "Nom de la nouvelle OU :"
$labelOUName.Location = New-Object System.Drawing.Point(20, 60)
$form.Controls.Add($labelOUName)

$textBoxOUName = New-Object System.Windows.Forms.TextBox
$textBoxOUName.Location = New-Object System.Drawing.Point(150, 58)
$textBoxOUName.Width = 300
$form.Controls.Add($textBoxOUName)

# CheckBox : Protection
$checkBoxProtected = New-Object System.Windows.Forms.CheckBox
$checkBoxProtected.Text = "Proteger contre la suppression"
$checkBoxProtected.Width = 350
$checkBoxProtected.Location = New-Object System.Drawing.Point(20, 90)
$checkBoxProtected.Checked = $true
$form.Controls.Add($checkBoxProtected)

# Bouton : Créer l'OU
$buttonCreateOU = New-Object System.Windows.Forms.Button
$buttonCreateOU.Text = "Creer l'OU"
$buttonCreateOU.Location = New-Object System.Drawing.Point(20, 120)
$buttonCreateOU.Add_Click({
    Create-OU -ParentOU $comboBoxOUParent.SelectedItem -OUName $textBoxOUName.Text -Protected $checkBoxProtected.Checked
})
$form.Controls.Add($buttonCreateOU)

# Suppression d'une OU
$labelDeleteOU = New-Object System.Windows.Forms.Label
$labelDeleteOU.Text = "Supprimer une OU :"
$labelDeleteOU.Location = New-Object System.Drawing.Point(20, 160)
$form.Controls.Add($labelDeleteOU)

$comboBoxOUDelete = New-Object System.Windows.Forms.ComboBox
$comboBoxOUDelete.Location = New-Object System.Drawing.Point(150, 158)
$comboBoxOUDelete.Width = 300
$form.Controls.Add($comboBoxOUDelete)

$buttonDeleteOU = New-Object System.Windows.Forms.Button
$buttonDeleteOU.Text = "Supprimer"
$buttonDeleteOU.Location = New-Object System.Drawing.Point(20, 190)
$buttonDeleteOU.Add_Click({ Delete-OU -OUName $comboBoxOUDelete.SelectedItem })
$form.Controls.Add($buttonDeleteOU)

Refresh-OUList
$form.ShowDialog()
