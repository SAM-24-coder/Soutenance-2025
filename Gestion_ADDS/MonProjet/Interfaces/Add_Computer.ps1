Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

# Fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Ajouter une machine au domaine Active Directory'
$form.Size = New-Object System.Drawing.Size(520, 580)
$form.StartPosition = 'CenterScreen'

# Champ - Nom de la machine
$lblComputer = New-Object System.Windows.Forms.Label
$lblComputer.Text = 'Nom de la machine :'
$lblComputer.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($lblComputer)

$txtComputer = New-Object System.Windows.Forms.TextBox
$txtComputer.Location = New-Object System.Drawing.Point(180, 20)
$txtComputer.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($txtComputer)

# Champ - OU cible
$lblOU = New-Object System.Windows.Forms.Label
$lblOU.Text = 'OU cible :'
$lblOU.Location = New-Object System.Drawing.Point(20, 60)
$form.Controls.Add($lblOU)

$cmbOU = New-Object System.Windows.Forms.ComboBox
$cmbOU.Location = New-Object System.Drawing.Point(180, 60)
$cmbOU.Size = New-Object System.Drawing.Size(300, 20)
$cmbOU.DropDownStyle = 'DropDownList'
$form.Controls.Add($cmbOU)

# Charger les OUs
$ous = Get-ADOrganizationalUnit -Filter * | Sort-Object DistinguishedName
foreach ($ou in $ous) {
    $cmbOU.Items.Add($ou.DistinguishedName)
}

# Champ - Utilisateur
$lblUser = New-Object System.Windows.Forms.Label
$lblUser.Text = 'Utilisateur (DOMAINE\user) :'
$lblUser.Location = New-Object System.Drawing.Point(20, 100)
$form.Controls.Add($lblUser)

$txtUser = New-Object System.Windows.Forms.TextBox
$txtUser.Location = New-Object System.Drawing.Point(180, 100)
$txtUser.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($txtUser)

# Champ - Mot de passe
$lblPass = New-Object System.Windows.Forms.Label
$lblPass.Text = 'Mot de passe :'
$lblPass.Location = New-Object System.Drawing.Point(20, 140)
$form.Controls.Add($lblPass)

$txtPass = New-Object System.Windows.Forms.MaskedTextBox
$txtPass.PasswordChar = '*'
$txtPass.Location = New-Object System.Drawing.Point(180, 140)
$txtPass.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($txtPass)

# Bouton - Ajouter au domaine
$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Text = 'Ajouter au domaine'
$btnAdd.Size = New-Object System.Drawing.Size(200, 35)
$btnAdd.Location = New-Object System.Drawing.Point(150, 180)
$form.Controls.Add($btnAdd)

# Label Liste des machines
$lblList = New-Object System.Windows.Forms.Label
$lblList.Text = 'Machines déjà dans le domaine :'
$lblList.Location = New-Object System.Drawing.Point(20, 230)
$form.Controls.Add($lblList)

# Liste des machines
$listComputers = New-Object System.Windows.Forms.ListView
$listComputers.Location = New-Object System.Drawing.Point(20, 250)
$listComputers.Size = New-Object System.Drawing.Size(460, 230)
$listComputers.View = [System.Windows.Forms.View]::Details
$listComputers.FullRowSelect = $true
$listComputers.GridLines = $true

$listComputers.Columns.Add("Nom", 140)
$listComputers.Columns.Add("OU", 220)
$listComputers.Columns.Add("Dernière connexion", 100)

$form.Controls.Add($listComputers)

# Bouton - Rafraîchir
$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = 'Rafraîchir la liste'
$btnRefresh.Size = New-Object System.Drawing.Size(160, 30)
$btnRefresh.Location = New-Object System.Drawing.Point(160, 495)
$form.Controls.Add($btnRefresh)

# Fonction - Charger les machines
function Load-Computers {
    $listComputers.Items.Clear()
    $computers = Get-ADComputer -Filter * -Properties LastLogonDate, DistinguishedName | Sort-Object Name

    foreach ($comp in $computers) {
        $item = New-Object System.Windows.Forms.ListViewItem($comp.Name)
        $ou = ($comp.DistinguishedName -split ',(?=OU=)')[1..99] -join ','  # extraire l'OU
        $item.SubItems.Add($ou)
        $item.SubItems.Add($comp.LastLogonDate.ToString("dd/MM/yyyy"))
        $listComputers.Items.Add($item)
    }
}

# Lancer au chargement
Load-Computers

# Action bouton Rafraîchir
$btnRefresh.Add_Click({
    Load-Computers
})

# Action bouton Ajouter
$btnAdd.Add_Click({
    $pcName = $txtComputer.Text
    $ouDN = $cmbOU.SelectedItem
    $domainUser = $txtUser.Text
    $domainPass = $txtPass.Text | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($domainUser, $domainPass)

    if (-not $pcName -or -not $ouDN -or -not $domainUser -or -not $domainPass) {
        [System.Windows.Forms.MessageBox]::Show("Tous les champs sont requis.", "Erreur", "OK", "Error")
        return
    }

    try {
        Invoke-Command -ComputerName $pcName -Credential $cred -ScriptBlock {
            param($dn, $domainCred)
            Add-Computer -DomainName (Get-ADDomain).DNSRoot -OUPath $dn -Credential $domainCred -Force -Restart
        } -ArgumentList $ouDN, $cred

        [System.Windows.Forms.MessageBox]::Show("Machine ajoutée avec succès !", "Succès", "OK", "Information")
        Load-Computers
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur : $_", "Erreur", "OK", "Error")
    }
})

# Affichage
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
$form.ShowDialog()
