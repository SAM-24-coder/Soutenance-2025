Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory
Import-Module GroupPolicy

function Set-LockGPO {
    param (
        [string]$GPOName,
        [string]$OU,
        [bool]$Enable,
        [int]$Timeout
    )

    # Créer la GPO si elle n'existe pas
    if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
        New-GPO -Name $GPOName | Out-Null
    }

    if ($Enable) {
        # Configurer les valeurs de registre
        Set-GPRegistryValue -Name $GPOName `
            -Key "HKCU\Control Panel\Desktop" `
            -ValueName "ScreenSaveTimeOut" `
            -Type String `
            -Value ($Timeout * 60)  # Convertir en secondes

        Set-GPRegistryValue -Name $GPOName `
            -Key "HKCU\Control Panel\Desktop" `
            -ValueName "ScreenSaverIsSecure" `
            -Type String `
            -Value "1"

        Set-GPRegistryValue -Name $GPOName `
            -Key "HKCU\Control Panel\Desktop" `
            -ValueName "ScreenSaveActive" `
            -Type String `
            -Value "1"
    } else {
        # Supprimer les paramètres de verrouillage
        Remove-GPRegistryValue -Name $GPOName -Key "HKCU\Control Panel\Desktop" -ValueName "ScreenSaveTimeOut" -ErrorAction SilentlyContinue
        Remove-GPRegistryValue -Name $GPOName -Key "HKCU\Control Panel\Desktop" -ValueName "ScreenSaverIsSecure" -ErrorAction SilentlyContinue
        Remove-GPRegistryValue -Name $GPOName -Key "HKCU\Control Panel\Desktop" -ValueName "ScreenSaveActive" -ErrorAction SilentlyContinue
    }

    # Lier la GPO à l’OU sélectionnée
    New-GPLink -Name $GPOName -Target $OU -Enforced No -ErrorAction SilentlyContinue
}

# === Interface graphique ===
$form = New-Object Windows.Forms.Form
$form.Text = "Verrouillage Automatique de Session"
$form.Size = New-Object Drawing.Size(500, 300)
$form.StartPosition = "CenterScreen"
$form.BackColor = "White"

# Label
$labelOU = New-Object Windows.Forms.Label
$labelOU.Text = "Sélectionnez une Unité d'Organisation (OU) :"
$labelOU.Location = "20,20"
$labelOU.Size = "440,20"
$form.Controls.Add($labelOU)

# ComboBox pour les OUs
$comboOU = New-Object Windows.Forms.ComboBox
$comboOU.Location = "20,50"
$comboOU.Size = "440,30"
$comboOU.DropDownStyle = 'DropDownList'
$form.Controls.Add($comboOU)

# Charger les OUs
$ous = Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName
$comboOU.Items.AddRange($ous)

# Label pour délai
$labelTimeout = New-Object Windows.Forms.Label
$labelTimeout.Text = "Délai avant verrouillage (en minutes) :"
$labelTimeout.Location = "20,100"
$labelTimeout.Size = "440,20"
$form.Controls.Add($labelTimeout)

# TextBox pour délai (minutes)
$txtTimeout = New-Object Windows.Forms.TextBox
$txtTimeout.Location = "20,130"
$txtTimeout.Size = "440,30"
$txtTimeout.Text = "5"  # Valeur par défaut
$form.Controls.Add($txtTimeout)

# Bouton ACTIVER
$btnEnable = New-Object Windows.Forms.Button
$btnEnable.Text = "Activer Verrouillage"
$btnEnable.Location = "50,180"
$btnEnable.Size = "170,40"
$btnEnable.BackColor = "DarkBlue"
$btnEnable.ForeColor = "White"
$btnEnable.Add_Click({
    if ($comboOU.SelectedItem) {
        $timeout = [int]$txtTimeout.Text
        if ($timeout -gt 0) {
            Set-LockGPO -GPOName "Verrouillage Auto Session" -OU $comboOU.SelectedItem -Enable $true -Timeout $timeout
            [Windows.Forms.MessageBox]::Show("✅ Verrouillage automatique activé pour : `n$($comboOU.SelectedItem) avec un délai de $timeout minutes.")
        } else {
            [Windows.Forms.MessageBox]::Show("Veuillez entrer un délai valide (en minutes).")
        }
    }
})
$form.Controls.Add($btnEnable)

# Bouton DESACTIVER
$btnDisable = New-Object Windows.Forms.Button
$btnDisable.Text = "Désactiver Verrouillage"
$btnDisable.Location = "260,180"
$btnDisable.Size = "170,40"
$btnDisable.BackColor = "Gray"
$btnDisable.ForeColor = "White"
$btnDisable.Add_Click({
    if ($comboOU.SelectedItem) {
        Set-LockGPO -GPOName "Verrouillage Auto Session" -OU $comboOU.SelectedItem -Enable $false -Timeout 0
        [Windows.Forms.MessageBox]::Show("🔓 Verrouillage automatique désactivé pour : `n$($comboOU.SelectedItem)")
    }
})
$form.Controls.Add($btnDisable)

$form.ShowDialog()
