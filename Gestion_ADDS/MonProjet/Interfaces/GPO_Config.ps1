Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory
Import-Module GroupPolicy

function Set-ControlPanelGPO {
    param (
        [string]$GPOName,
        [string]$OU,
        [bool]$Enable
    )

    # Créer la GPO si elle n'existe pas
    if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
        New-GPO -Name $GPOName | Out-Null
    }

    # Appliquer ou retirer la clé de registre
    if ($Enable) {
        Set-GPRegistryValue -Name $GPOName `
            -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
            -ValueName "NoControlPanel" `
            -Type DWord `
            -Value 1
    } else {
        Remove-GPRegistryValue -Name $GPOName `
            -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
            -ValueName "NoControlPanel" `
            -ErrorAction SilentlyContinue
    }

    # Lier la GPO à l’OU sélectionnée (corrigé ici !)
    New-GPLink -Name $GPOName -Target $OU -Enforced No -ErrorAction SilentlyContinue
}

# === Interface graphique ===
$form = New-Object Windows.Forms.Form
$form.Text = "Blocage du Panneau de Configuration"
$form.Size = New-Object Drawing.Size(500, 250)
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

# Bouton ACTIVER
$btnEnable = New-Object Windows.Forms.Button
$btnEnable.Text = "Bloquer le Panneau"
$btnEnable.Location = "50,100"
$btnEnable.Size = "170,40"
$btnEnable.BackColor = "DarkRed"
$btnEnable.ForeColor = "White"
$btnEnable.Add_Click({
    if ($comboOU.SelectedItem) {
        Set-ControlPanelGPO -GPOName "Blocage Panneau de Configuration" -OU $comboOU.SelectedItem -Enable $true
        [Windows.Forms.MessageBox]::Show("✅ Panneau de configuration bloqué pour : `n$($comboOU.SelectedItem)")
    }
})
$form.Controls.Add($btnEnable)

# Bouton DESACTIVER
$btnDisable = New-Object Windows.Forms.Button
$btnDisable.Text = "Débloquer le Panneau"
$btnDisable.Location = "260,100"
$btnDisable.Size = "170,40"
$btnDisable.BackColor = "Green"
$btnDisable.ForeColor = "White"
$btnDisable.Add_Click({
    if ($comboOU.SelectedItem) {
        Set-ControlPanelGPO -GPOName "Blocage Panneau de Configuration" -OU $comboOU.SelectedItem -Enable $false
        [Windows.Forms.MessageBox]::Show("✅ Panneau de configuration autorisé pour : `n$($comboOU.SelectedItem)")
    }
})
$form.Controls.Add($btnDisable)

$form.ShowDialog()
