Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory
Import-Module GroupPolicy

# Récupérer les OUs
$ouList = Get-ADOrganizationalUnit -Filter * | Sort-Object Name

# Création de la fenêtre
$form = New-Object System.Windows.Forms.Form
$form.Text = "GPO - Mot de Passe avec OU et Complexité"
$form.Size = New-Object System.Drawing.Size(500,700)

# Label pour le nom du GPO
$lblGpoName = New-Object System.Windows.Forms.Label
$lblGpoName.Text = "Nom du GPO :"
$lblGpoName.Location = '10,20'
$form.Controls.Add($lblGpoName)

# TextBox pour entrer le nom du GPO
$txtGpoName = New-Object System.Windows.Forms.TextBox
$txtGpoName.Location = '150,20'
$txtGpoName.Width = 300
$form.Controls.Add($txtGpoName)

# Checkbox complexité
$chkComplexity = New-Object System.Windows.Forms.CheckBox
$chkComplexity.Text = "Activer la complexité du mot de passe"
$chkComplexity.Location = '10,60'
$form.Controls.Add($chkComplexity)

# Longueur minimale
$lblLength = New-Object System.Windows.Forms.Label
$lblLength.Text = "Longueur minimale :"
$lblLength.Location = '10,100'
$form.Controls.Add($lblLength)

$txtLength = New-Object System.Windows.Forms.TextBox
$txtLength.Location = '150,100'
$form.Controls.Add($txtLength)

# Checkbox Majuscules
$chkUppercase = New-Object System.Windows.Forms.CheckBox
$chkUppercase.Text = "Exiger des majuscules"
$chkUppercase.Location = '10,140'
$form.Controls.Add($chkUppercase)

# Checkbox Minuscules
$chkLowercase = New-Object System.Windows.Forms.CheckBox
$chkLowercase.Text = "Exiger des minuscules"
$chkLowercase.Location = '10,180'
$form.Controls.Add($chkLowercase)

# Checkbox Caractères spéciaux
$chkSpecialChars = New-Object System.Windows.Forms.CheckBox
$chkSpecialChars.Text = "Exiger des caractères spéciaux"
$chkSpecialChars.Location = '10,220'
$form.Controls.Add($chkSpecialChars)

# Label OU
$lblOU = New-Object System.Windows.Forms.Label
$lblOU.Text = "Sélectionner l'OU :"
$lblOU.Location = '10,260'
$form.Controls.Add($lblOU)

# ComboBox OU
$cmbOU = New-Object System.Windows.Forms.ComboBox
$cmbOU.Location = '150,260'
$cmbOU.Width = 300
$cmbOU.DropDownStyle = 'DropDownList'
$form.Controls.Add($cmbOU)

# Remplir la combo avec les OU
foreach ($ou in $ouList) {
    $cmbOU.Items.Add($ou.DistinguishedName)
}

# Label Aperçu
$lblPreview = New-Object System.Windows.Forms.Label
$lblPreview.Text = "Aperçu des paramètres :"
$lblPreview.Location = '10,300'
$form.Controls.Add($lblPreview)

# Zone Aperçu
$txtPreview = New-Object System.Windows.Forms.TextBox
$txtPreview.Location = '10,330'
$txtPreview.Size = New-Object System.Drawing.Size(460,200)
$txtPreview.Multiline = $true
$txtPreview.ReadOnly = $true
$form.Controls.Add($txtPreview)

# Mise à jour Aperçu
$updatePreview = {
    $complex = if ($chkComplexity.Checked) { "Oui" } else { "Non" }
    $length = $txtLength.Text
    $uppercase = if ($chkUppercase.Checked) { "Oui" } else { "Non" }
    $lowercase = if ($chkLowercase.Checked) { "Oui" } else { "Non" }
    $special = if ($chkSpecialChars.Checked) { "Oui" } else { "Non" }
    $ou = $cmbOU.SelectedItem
    $gpoName = $txtGpoName.Text

    $txtPreview.Text = "Nom du GPO : $gpoName`r`nComplexité du mot de passe : $complex`r`nLongueur minimale : $length`r`nMajuscules : $uppercase`r`nMinuscules : $lowercase`r`nCaractères spéciaux : $special`r`nOU ciblée : $ou"
}

# Ajout des événements pour la mise à jour dynamique de l'aperçu
$chkComplexity.Add_CheckedChanged($updatePreview)
$txtLength.Add_TextChanged($updatePreview)
$chkUppercase.Add_CheckedChanged($updatePreview)
$chkLowercase.Add_CheckedChanged($updatePreview)
$chkSpecialChars.Add_CheckedChanged($updatePreview)
$cmbOU.Add_SelectedIndexChanged($updatePreview)
$txtGpoName.Add_TextChanged($updatePreview)

# Bouton Créer GPO
$btnCreate = New-Object System.Windows.Forms.Button
$btnCreate.Text = "Créer GPO"
$btnCreate.Location = '10,550'
$btnCreate.Add_Click({
    try {
        # Récupérer les valeurs
        $gpoName = $txtGpoName.Text
        if (-not $gpoName) {
            [System.Windows.Forms.MessageBox]::Show("Veuillez entrer un nom pour le GPO.")
            return
        }

        $complex = if ($chkComplexity.Checked) { 1 } else { 0 }
        $length = [int]$txtLength.Text
        $uppercase = if ($chkUppercase.Checked) { 1 } else { 0 }
        $lowercase = if ($chkLowercase.Checked) { 1 } else { 0 }
        $special = if ($chkSpecialChars.Checked) { 1 } else { 0 }
        $ou = $cmbOU.SelectedItem

        if (-not $ou) {
            [System.Windows.Forms.MessageBox]::Show("Veuillez sélectionner une OU.")
            return
        }

        $existingGpo = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
        if (-not $existingGpo) {
            $gpo = New-GPO -Name $gpoName
        }

        # Appliquer les valeurs
        Set-GPRegistryValue -Name $gpoName -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "PasswordComplexity" -Type DWord -Value $complex
        Set-GPRegistryValue -Name $gpoName -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "MinimumPasswordLength" -Type DWord -Value $length

        # Appliquer les règles de complexité de mot de passe
        Set-GPRegistryValue -Name $gpoName -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "PasswordMustMeetComplexity" -Type DWord -Value $complex
        Set-GPRegistryValue -Name $gpoName -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "Uppercase" -Type DWord -Value $uppercase
        Set-GPRegistryValue -Name $gpoName -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "Lowercase" -Type DWord -Value $lowercase
        Set-GPRegistryValue -Name $gpoName -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "SpecialChars" -Type DWord -Value $special

        # Lier la GPO à l'OU (Utilisation de "Yes" ou "No" pour Enforced)
        New-GPLink -Name $gpoName -Target $ou -Enforced "No"

        [System.Windows.Forms.MessageBox]::Show("GPO créée et liée à l'OU avec succès.")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur : $($_.Exception.Message)")
    }
})
$form.Controls.Add($btnCreate)

# Affichage
$form.ShowDialog()
