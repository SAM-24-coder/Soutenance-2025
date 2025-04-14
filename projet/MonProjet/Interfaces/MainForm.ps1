Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Importer la fonction pour rÃ©cupÃ©rer les utilisateurs
. "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Fonctions\UserFunctions.ps1"

function Show-MainForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Suivi des Comptes"
    $form.Size = New-Object System.Drawing.Size(700, 500)

    # Champ de recherche par nom
    $searchBox = New-Object System.Windows.Forms.TextBox
    $searchBox.Location = New-Object System.Drawing.Point(10, 10)
    $searchBox.Size = New-Object System.Drawing.Size(200, 30)

    # Bouton de recherche
    $searchButton = New-Object System.Windows.Forms.Button
    $searchButton.Text = "Rechercher"
    $searchButton.Location = New-Object System.Drawing.Point(220, 10)
    $searchButton.Size = New-Object System.Drawing.Size(100, 30)

    # Filtre de statut
    $statusComboBox = New-Object System.Windows.Forms.ComboBox
    $statusComboBox.Location = New-Object System.Drawing.Point(330, 10)
    $statusComboBox.Size = New-Object System.Drawing.Size(240, 30)
    $statusComboBox.Items.Add("Tous les utilisateurs")
    $statusComboBox.Items.Add("Actif")
    $statusComboBox.Items.Add("BloquÃ©")
    $statusComboBox.SelectedIndex = 0  # SÃ©lectionner "Tous les utilisateurs" par dÃ©faut

    # ListView pour afficher les utilisateurs
    $accountsListView = New-Object System.Windows.Forms.ListView
    $accountsListView.Location = New-Object System.Drawing.Point(10, 50)
    $accountsListView.Size = New-Object System.Drawing.Size(660, 350)
    $accountsListView.View = [System.Windows.Forms.View]::Details

    # Ajout des colonnes
    $accountsListView.Columns.Add("Nom d'utilisateur", 200)
    $accountsListView.Columns.Add("Statut", 100)
    $accountsListView.Columns.Add("Expiration", 100)
    $accountsListView.Columns.Add("Action", 100)

    # Ã‰vÃ©nement de clic sur le bouton "Rechercher"
    $searchButton.Add_Click({
        $accountsListView.Items.Clear()  # Vider la liste prÃ©cÃ©dente
        $searchTerm = $searchBox.Text.Trim()
        $statusFilter = $statusComboBox.SelectedItem

        # RÃ©cupÃ©rer tous les utilisateurs
       $users = Get-ADUsers

        # Filtrer les utilisateurs en fonction du statut et du nom
        foreach ($user in $users) {
            $statut = if ($user.Enabled) { 'Actif' } else { 'BloquÃ©' }
            if (($statusFilter -eq "Tous les utilisateurs" -or 
                 ($statusFilter -eq "Actif" -and $user.Enabled) -or 
                 ($statusFilter -eq "BloquÃ©" -and -not $user.Enabled)) -and
                ($user.Name -like "*$searchTerm*")) {

                $expirationDate = (Get-ADUser $user.SamAccountName -Properties AccountExpirationDate).AccountExpirationDate
                $expirationString = if ($expirationDate) { $expirationDate.ToString('yyyy-MM-dd') } else { 'N/A' }

                # Ajouter l'utilisateur au ListView
                $item = New-Object System.Windows.Forms.ListViewItem
                $item.Text = $user.Name
                $item.SubItems.Add($statut)
                $item.SubItems.Add($expirationString)
                $item.SubItems.Add("Modifier")  # Placeholder pour actions possibles

                $accountsListView.Items.Add($item)
            }
        }
    })

     # Bouton pour ajouter un utilisateur
 #   $addButton = New-Object System.Windows.Forms.Button
 #   $addButton.Text = "Ajouter Utilisateur"
 #   $addButton.Location = New-Object System.Drawing.Point(10, 410)
 #   $addButton.Size = New-Object System.Drawing.Size(150, 30)
 #   $addButton.Add_Click({
 #   $username = Show-InputBox -message "Entrez le nom d'utilisateur a  ajouter:" -title "Ajouter Utilisateur"
 #   if (![string]::IsNullOrWhiteSpace($username)) {
 #       try {
 #           New-ADUser -Name $username -SamAccountName $username -UserPrincipalName "$username@localhost.local" -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) -Enabled $true
 #           RefreshUserList
 #           [System.Windows.Forms.MessageBox]::Show("Utilisateur ajoutÃ© avec succÃ¨s.", "SuccÃ¨s")
 #       } catch {
 #           [System.Windows.Forms.MessageBox]::Show("Erreur lors de l'ajout de l'utilisateur: $_", "Erreur")
#        }
#    }
#})


    # Bouton pour changer le mot de passe
    $changePasswordButton = New-Object System.Windows.Forms.Button
    $changePasswordButton.Text = "Changer Mot de Passe"
    $changePasswordButton.Location = New-Object System.Drawing.Point(180, 410)
    $changePasswordButton.Size = New-Object System.Drawing.Size(150, 30)
    $changePasswordButton.Add_Click({
    if ($accountsListView.SelectedItems.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Veuillez sÃ©lectionner un utilisateur dont vous souhaitez changer le mot de passe.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK)
        return
    }
    $selectedUser = $accountsListView.SelectedItems[0].Text
    $newPassword = Show-InputBox -message "Entrez le nouveau mot de passe pour $selectedUser" -title "Changer Mot de Passe"
    if (![string]::IsNullOrWhiteSpace($newPassword)) {
        try {
            Set-ADAccountPassword -Identity $selectedUser -NewPassword (ConvertTo-SecureString $newPassword -AsPlainText -Force)
            [System.Windows.Forms.MessageBox]::Show("Mot de passe changÃ© avec succÃ¨s.", "SuccÃ¨s")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Erreur lors du changement de mot de passe: $_", "Erreur")
        }
    }
})

# Bouton pour supprimer un utilisateur
$removeButton = New-Object System.Windows.Forms.Button
$removeButton.Text = "Supprimer Utilisateur"
$removeButton.Location = New-Object System.Drawing.Point(350, 410)
$removeButton.Size = New-Object System.Drawing.Size(150, 30)
$removeButton.Add_Click({
    if ($accountsListView.SelectedItems.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Veuillez sÃ©lectionner un utilisateur Ã  supprimer.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK)
        return
    }
    $selectedUser = $accountsListView.SelectedItems[0].Text

    # Supprimer l'utilisateur
    try {
        # Utilisez le SamAccountName
        Remove-ADUser -Identity $selectedUser -Confirm:$false
        RefreshUserList
        [System.Windows.Forms.MessageBox]::Show("Utilisateur supprimÃ© avec succÃ¨s.", "SuccÃ¨s")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erreur lors de la suppression de l'utilisateur: $_", "Erreur")
    }
})  

 # Fonction pour rafraÃ®chir la liste des utilisateurs
    function RefreshUserList {
        $accountsListView.Items.Clear()  # Vider la liste prÃ©cÃ©dente
        $users = Get-ADUsers  # RÃ©cupÃ©rer tous les utilisateurs
        foreach ($user in $users) {
            $statut = if ($user.Enabled) { 'Actif' } else { 'BloquÃ©' }
            $expirationDate = (Get-ADUser $user.SamAccountName -Properties AccountExpirationDate).AccountExpirationDate
            $lastLogonDate = (Get-ADUser $user.SamAccountName -Properties LastLogonDate).LastLogonDate

            $expirationString = if ($expirationDate) { $expirationDate.ToString('yyyy-MM-dd') } else { 'N/A' }
            $lastLogonString = if ($lastLogonDate) { $lastLogonDate.ToString('yyyy-MM-dd HH:mm:ss') } else { 'Jamais' }

            $item = New-Object System.Windows.Forms.ListViewItem
            $item.Text = $user.Name
            $item.SubItems.Add($statut)
            $item.SubItems.Add($expirationString)
            $item.SubItems.Add($lastLogonString)
            $accountsListView.Items.Add($item)
        }
    }

    
    # Bouton pour changer la date d'expiration
    $changeExpirationButton = New-Object System.Windows.Forms.Button
    $changeExpirationButton.Text = "Changer Date d'Expiration"
    $changeExpirationButton.Location = New-Object System.Drawing.Point(520, 410)
    $changeExpirationButton.Size = New-Object System.Drawing.Size(150, 30)
    $changeExpirationButton.Add_Click({
        if ($accountsListView.SelectedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Veuillez sÃ©lectionner un utilisateur dont vous souhaitez changer la date d'expiration.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK)
            return
        }
        $selectedUser = $accountsListView.SelectedItems[0].Text
        $newExpirationDateString = Show-InputBox -message "Entrez la nouvelle date d'expiration (format: AAAA-MM-JJ):" -title "Changer Date d'Expiration"
        if (![string]::IsNullOrWhiteSpace($newExpirationDateString)) {
            try {
                $newExpirationDate = [datetime]::Parse($newExpirationDateString)
                # Modifier la date d'expiration
                Set-ADUser -Identity $selectedUser -AccountExpirationDate $newExpirationDate
                [System.Windows.Forms.MessageBox]::Show("Date d'expiration changÃ©e avec succÃ¨s.", "SuccÃ¨s")
                RefreshUserList
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Erreur lors du changement de la date d'expiration: $_", "Erreur")
            }
        }
    })


    # Ajouter les contrÃ´les au formulaire
    $form.Controls.Add($searchBox)
    $form.Controls.Add($searchButton)
    $form.Controls.Add($statusComboBox)
    $form.Controls.Add($accountsListView)
    $form.Controls.Add($addButton)
    $form.Controls.Add($changePasswordButton)
    $form.Controls.Add($removeButton)
    $form.Controls.Add($changeExpirationButton)

    # Afficher le formulaire
    $form.Add_Shown({$form.Activate()})
    [void]$form.ShowDialog()
}

# Appel de la fonction pour afficher le formulaire
#Show-MainForm



                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                