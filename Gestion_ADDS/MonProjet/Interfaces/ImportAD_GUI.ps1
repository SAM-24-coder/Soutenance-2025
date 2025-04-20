# Charger les bibliothèques Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Importer les fonctions AD depuis un fichier séparé
. "C:\Users\Administrateur\Desktop\Gestion_ADDS\MonProjet\Fonctions\ImportAD_Functions.ps1"

# Fonction principale pour afficher l'interface
function Show-ImportADForm {
    # Créer la fenêtre principale
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Importation des utilisateurs AD"
    $form.Size = New-Object System.Drawing.Size(600, 600)
    $form.StartPosition = "CenterScreen"

    # Champ : Sélection du fichier CSV
    $labelCSV = New-Object System.Windows.Forms.Label
    $labelCSV.Text = "Fichier CSV :"
    $labelCSV.Location = New-Object System.Drawing.Point(20, 20)
    $form.Controls.Add($labelCSV)

    $textBoxCSV = New-Object System.Windows.Forms.TextBox
    $textBoxCSV.Location = New-Object System.Drawing.Point(100, 20)
    $textBoxCSV.Width = 350
    $form.Controls.Add($textBoxCSV)

    $buttonBrowse = New-Object System.Windows.Forms.Button
    $buttonBrowse.Text = "Parcourir..."
    $buttonBrowse.Location = New-Object System.Drawing.Point(460, 18)
    $buttonBrowse.Add_Click({
        $FileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $FileDialog.Filter = "Fichiers CSV (*.csv)|*.csv"
        if ($FileDialog.ShowDialog() -eq "OK") {
            $textBoxCSV.Text = $FileDialog.FileName
        }
    })
    $form.Controls.Add($buttonBrowse)

    # ListView pour afficher les utilisateurs du CSV
    $listView = New-Object System.Windows.Forms.ListView
    $listView.Location = New-Object System.Drawing.Point(20, 60)
    $listView.Size = New-Object System.Drawing.Size(540, 250)
    $listView.View = 'Details'
    $listView.FullRowSelect = $true
    $listView.GridLines = $true
    $listView.Columns.Add("Prénom", 100)
    $listView.Columns.Add("Nom", 100)
    $listView.Columns.Add("Login", 100)
    $listView.Columns.Add("Email", 200)
    $form.Controls.Add($listView)

    # Bouton : Charger le CSV
    $buttonLoadCSV = New-Object System.Windows.Forms.Button
    $buttonLoadCSV.Text = "Charger le CSV"
    $buttonLoadCSV.Width = 100
    $buttonLoadCSV.Location = New-Object System.Drawing.Point(20, 320)
    $buttonLoadCSV.Add_Click({
        $CSVFile = $textBoxCSV.Text
        if (-not (Test-Path $CSVFile)) {
            [System.Windows.Forms.MessageBox]::Show("Fichier non trouvé !", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }
        
        $CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8
        $listView.Items.Clear()
        Foreach ($Utilisateur in $CSVData) {
            $item = New-Object System.Windows.Forms.ListViewItem($Utilisateur.Prenom)
            $item.SubItems.Add($Utilisateur.Nom)
            $item.SubItems.Add(($Utilisateur.Prenom).Substring(0,1) + "." + $Utilisateur.Nom)
            $item.SubItems.Add(($Utilisateur.Prenom).Substring(0,1) + "." + $Utilisateur.Nom + "@localhost.local")
            $listView.Items.Add($item)
        }
    })
    $form.Controls.Add($buttonLoadCSV)

    # Zone de logs
    $textBoxLogs = New-Object System.Windows.Forms.TextBox
    $textBoxLogs.Location = New-Object System.Drawing.Point(20, 350)
    $textBoxLogs.Size = New-Object System.Drawing.Size(540, 80)
    $textBoxLogs.Multiline = $true
    $textBoxLogs.ScrollBars = "Vertical"
    $form.Controls.Add($textBoxLogs)

    # Bouton : Importer dans AD
    $buttonImportAD = New-Object System.Windows.Forms.Button
    $buttonImportAD.Text = "Importer dans Active Directory"
    $buttonImportAD.Width = 200
    $buttonImportAD.Location = New-Object System.Drawing.Point(20, 440)
    $buttonImportAD.Add_Click({
        $CSVFile = $textBoxCSV.Text
        if (-not (Test-Path $CSVFile)) {
            [System.Windows.Forms.MessageBox]::Show("Fichier non trouvé !", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        $CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8
        Import-UsersToAD -CSVData $CSVData -LogsBox $textBoxLogs
    })
    $form.Controls.Add($buttonImportAD)

    # Afficher la fenêtre
    $form.ShowDialog()
}

# Exemple d'appel de la fonction
Show-ImportADForm
