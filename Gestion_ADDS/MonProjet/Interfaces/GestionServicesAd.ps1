Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-ServiceManagerForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Gestion des Services AD"
    $form.Size = New-Object System.Drawing.Size(700, 500)
    
    # Champ de recherche
    $searchBox = New-Object System.Windows.Forms.TextBox
    $searchBox.Location = New-Object System.Drawing.Point(10, 10)
    $searchBox.Size = New-Object System.Drawing.Size(200, 30)
    
    # Bouton de recherche
    $searchButton = New-Object System.Windows.Forms.Button
    $searchButton.Text = "Rechercher"
    $searchButton.Location = New-Object System.Drawing.Point(220, 10)
    $searchButton.Size = New-Object System.Drawing.Size(100, 30)
    
    # ListView pour afficher les services
    $servicesListView = New-Object System.Windows.Forms.ListView
    $servicesListView.Location = New-Object System.Drawing.Point(10, 50)
    $servicesListView.Size = New-Object System.Drawing.Size(660, 350)
    $servicesListView.View = [System.Windows.Forms.View]::Details
    $servicesListView.FullRowSelect = $true
    
    # Colonnes
    $servicesListView.Columns.Add("Nom du Service", 250)
    $servicesListView.Columns.Add("État", 100)
    $servicesListView.Columns.Add("Démarrage", 150)
    
    # Bouton démarrer
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Text = "Démarrer"
    $startButton.Location = New-Object System.Drawing.Point(10, 420)
    $startButton.Size = New-Object System.Drawing.Size(150, 30)
    
    # Bouton arrêter
    $stopButton = New-Object System.Windows.Forms.Button
    $stopButton.Text = "Arrêter"
    $stopButton.Location = New-Object System.Drawing.Point(180, 420)
    $stopButton.Size = New-Object System.Drawing.Size(150, 30)
    
    # Fonction de mise à jour de la liste
    function RefreshServiceList {
        $servicesListView.Items.Clear()
        $services = Get-ServicesList -Filter $searchBox.Text.Trim()
        foreach ($service in $services) {
            $item = New-Object System.Windows.Forms.ListViewItem($service.DisplayName)
            $item.SubItems.Add($service.Status)
            $item.SubItems.Add($service.StartType)
            $servicesListView.Items.Add($item)
        }
    }
    
    # Événement de recherche
    $searchButton.Add_Click({ RefreshServiceList })
    
    # Démarrer un service
    $startButton.Add_Click({
        if ($servicesListView.SelectedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Veuillez sélectionner un service.", "Erreur")
            return
        }
        $selectedService = $servicesListView.SelectedItems[0].Text
        Start-SelectedService -ServiceName $selectedService
        RefreshServiceList
    })
    
    # Arrêter un service
    $stopButton.Add_Click({
        if ($servicesListView.SelectedItems.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Veuillez sélectionner un service.", "Erreur")
            return
        }
        $selectedService = $servicesListView.SelectedItems[0].Text
        Stop-SelectedService -ServiceName $selectedService
        RefreshServiceList
    })
    
    # Ajouter les éléments à l'interface
    $form.Controls.Add($searchBox)
    $form.Controls.Add($searchButton)
    $form.Controls.Add($servicesListView)
    $form.Controls.Add($startButton)
    $form.Controls.Add($stopButton)
    
    # Afficher le formulaire
    $form.ShowDialog()
}

# Exécuter l'interface
Show-ServiceManagerForm
