function Show-GPOWallpaperConfigForm {
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null

    # Création de la fenêtre
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'GPO - Configuration du Fond d écran'
    $form.Size = New-Object System.Drawing.Size(600,600)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = [System.Drawing.Color]::White

    # Ajout d'un titre stylisé
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = 'Configuration du Fond d écran'
    $lblTitle.Font = New-Object System.Drawing.Font('Arial', 12, [System.Drawing.FontStyle]::Bold)
    $lblTitle.ForeColor = [System.Drawing.Color]::DarkBlue
    $lblTitle.AutoSize = $true
    $lblTitle.Location = New-Object System.Drawing.Point(200,10)
    $form.Controls.Add($lblTitle)

    # Champ texte pour définir le nom de la GPO
    $lblGPOName = New-Object System.Windows.Forms.Label
    $lblGPOName.Text = 'Nom de la GPO :'
    $lblGPOName.Location = New-Object System.Drawing.Point(20,50)
    $form.Controls.Add($lblGPOName)

    $txtGPOName = New-Object System.Windows.Forms.TextBox
    $txtGPOName.Location = New-Object System.Drawing.Point(180,50)
    $txtGPOName.Size = New-Object System.Drawing.Size(250,20)
    $txtGPOName.Text = 'FondEcranGPO'
    $form.Controls.Add($txtGPOName)

    # Bouton de sélection d'image
    $btnSelectImage = New-Object System.Windows.Forms.Button
    $btnSelectImage.Text = 'Sélectionner une image'
    $btnSelectImage.Location = New-Object System.Drawing.Point(20,80)
    $btnSelectImage.Size = New-Object System.Drawing.Size(150,30)
    $btnSelectImage.BackColor = [System.Drawing.Color]::LightGray
    $btnSelectImage.FlatStyle = 'Flat'
    $btnSelectImage.Add_Click({
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = 'Images (*.jpg;*.png)|*.jpg;*.png'
        if ($openFileDialog.ShowDialog() -eq 'OK') {
            $txtImagePath.Text = $openFileDialog.FileName
        }
    })
    $form.Controls.Add($btnSelectImage)

    # Champ texte pour afficher le chemin de l'image
    $txtImagePath = New-Object System.Windows.Forms.TextBox
    $txtImagePath.Location = New-Object System.Drawing.Point(180,85)
    $txtImagePath.Size = New-Object System.Drawing.Size(250,20)
    $form.Controls.Add($txtImagePath)

    # Liste déroulante des OUs
    $lblOU = New-Object System.Windows.Forms.Label
    $lblOU.Text = 'Sélectionner une OU (optionnel) :'
    $lblOU.Location = New-Object System.Drawing.Point(20,120)
    $form.Controls.Add($lblOU)

    $cmbOU = New-Object System.Windows.Forms.ComboBox
    $cmbOU.Location = New-Object System.Drawing.Point(180,120)
    $cmbOU.Size = New-Object System.Drawing.Size(250,20)
    $form.Controls.Add($cmbOU)

    # Charger les OUs automatiquement
    Import-Module ActiveDirectory
    $OUs = Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName
    $cmbOU.Items.AddRange($OUs)

    # Bouton d'application de la GPO
    $btnApplyGPO = New-Object System.Windows.Forms.Button
    $btnApplyGPO.Text = 'Appliquer la GPO'
    $btnApplyGPO.Location = New-Object System.Drawing.Point(150,160)
    $btnApplyGPO.Size = New-Object System.Drawing.Size(150,40)
    $btnApplyGPO.BackColor = [System.Drawing.Color]::DarkBlue
    $btnApplyGPO.ForeColor = [System.Drawing.Color]::White
    $btnApplyGPO.FlatStyle = 'Flat'
    $btnApplyGPO.Add_Click({
        $gpoName = $txtGPOName.Text
        $imagePath = $txtImagePath.Text
        $ouPath = $cmbOU.SelectedItem

        if (-not $gpoName) {
            [System.Windows.Forms.MessageBox]::Show('Veuillez entrer un nom de GPO.')
            return
        }
        
        if (-not $imagePath) {
            [System.Windows.Forms.MessageBox]::Show('Veuillez sélectionner une image.')
            return
        }
        
        if (-not (Get-GPO -Name $gpoName -ErrorAction SilentlyContinue)) {
            New-GPO -Name $gpoName | Out-Null
        }

        # Définition des paramètres de registre pour le fond d'écran
        $registryPath = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System"
        Set-GPRegistryValue -Name $gpoName -Key $registryPath -ValueName "Wallpaper" -Type String -Value $imagePath
        Set-GPRegistryValue -Name $gpoName -Key $registryPath -ValueName "WallpaperStyle" -Type String -Value "2"
        Set-GPRegistryValue -Name $gpoName -Key $registryPath -ValueName "NoChangingWallPaper" -Type DWord -Value 1

        if ($ouPath) {
            New-GPLink -Name $gpoName -Target $ouPath -Enforced Yes
        }

        gpupdate /force | Out-Null
        Refresh-GPOList
    })
    $form.Controls.Add($btnApplyGPO)

    # Liste des GPO
    $lstGPOs = New-Object System.Windows.Forms.ListView
    $lstGPOs.Location = New-Object System.Drawing.Point(20,230)
    $lstGPOs.Size = New-Object System.Drawing.Size(550,200)
    $lstGPOs.View = [System.Windows.Forms.View]::Details
    $lstGPOs.FullRowSelect = $true
    $lstGPOs.Columns.Add('Nom de la GPO', 200)
    $lstGPOs.Columns.Add('OU Associée', 200)
    $lstGPOs.Columns.Add('Statut', 150)
    $form.Controls.Add($lstGPOs)

    # Bouton de suppression de la GPO sélectionnée
    $btnDeleteGPO = New-Object System.Windows.Forms.Button
    $btnDeleteGPO.Text = 'Supprimer la GPO'
    $btnDeleteGPO.Location = New-Object System.Drawing.Point(150,450)
    $btnDeleteGPO.Size = New-Object System.Drawing.Size(150,40)
    $btnDeleteGPO.BackColor = [System.Drawing.Color]::DarkRed
    $btnDeleteGPO.ForeColor = [System.Drawing.Color]::White
    $btnDeleteGPO.FlatStyle = 'Flat'
    $btnDeleteGPO.Add_Click({
        if ($lstGPOs.SelectedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show('Veuillez sélectionner une GPO à supprimer.')
            return
        }
        [System.Windows.Forms.MessageBox]::Show('GPO supprimé avec succés')
        $gpoName = $lstGPOs.SelectedItems[0].Text
        Remove-GPO -Name $gpoName -Confirm:$false
        Refresh-GPOList
    })
    $form.Controls.Add($btnDeleteGPO)

    function Refresh-GPOList {
        $lstGPOs.Items.Clear()
        $gpos = Get-GPO -All
        foreach ($gpo in $gpos) {
            $status = "appliquée"
            $linkedOUs = Get-GPInheritance -Target (Get-ADDomain).DistinguishedName | Where-Object { $_.GpoLinks.DisplayName -eq $gpo.DisplayName }
            if ($linkedOUs) { $status = "Non appliquée" }
            $item = New-Object System.Windows.Forms.ListViewItem($gpo.DisplayName)
            $item.SubItems.Add(($linkedOUs.Target -join ', '))
            $item.SubItems.Add($status)
            $lstGPOs.Items.Add($item)
        }
    }

    Refresh-GPOList
    $form.ShowDialog()
}

Show-GPOWallpaperConfigForm
