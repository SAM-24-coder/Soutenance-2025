# Fonction pour récupérer les Unites d'Organisation (OU) existantes
function Get-OUList {
    return Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName
}

# Fonction pour vérifier la validité du nom de l'OU
function Validate-OUName {
    param ([string]$OUName)
    return $OUName -match "^[a-zA-Z0-9\s\-_]+$"  # Autorise lettres, chiffres, espaces, tirets et underscores
}

# Fonction pour créer une nouvelle OU
function Create-OU {
    param (
        [string]$ParentOU,
        [string]$OUName,
        [bool]$Protected
    )

    if (-not $OUName) {
        [System.Windows.Forms.MessageBox]::Show("Veuillez entrer un nom pour l'OU.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    if (-not (Validate-OUName -OUName $OUName)) {
        [System.Windows.Forms.MessageBox]::Show("Nom d'OU invalide ! Caractères autorisés : lettres, chiffres, espaces, tirets (-) et underscores (_).", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $NewOU_DN = "OU=$OUName,$ParentOU"

    if (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $NewOU_DN} -ErrorAction SilentlyContinue) {
        [System.Windows.Forms.MessageBox]::Show("L'OU '$OUName' existe déjà !", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    } else {
        if ([System.Windows.Forms.MessageBox]::Show("Voulez-vous vraiment créer l'OU '$OUName' ?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) -eq "Yes") {
            try {
                New-ADOrganizationalUnit -Name $OUName -Path $ParentOU -ProtectedFromAccidentalDeletion $Protected
                [System.Windows.Forms.MessageBox]::Show("L'OU '$OUName' a été créée avec succès.", "Succès", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                Refresh-OUList  # Mise à jour de la liste
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Erreur lors de la création de l'OU : $_", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    }
}

# Fonction pour supprimer une OU existante
function Delete-OU {
    param ([string]$OUName)

    if (-not $OUName) {
        [System.Windows.Forms.MessageBox]::Show("Veuillez sélectionner une OU à supprimer.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    if ([System.Windows.Forms.MessageBox]::Show("Voulez-vous vraiment supprimer l'OU '$OUName' ?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning) -eq "Yes") {
        try {
            Remove-ADOrganizationalUnit -Identity $OUName -Confirm:$false
            [System.Windows.Forms.MessageBox]::Show("L'OU '$OUName' a été supprimée.", "Succès", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            Refresh-OUList  # Mise à jour de la liste
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Erreur lors de la suppression de l'OU : $_", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
}

# Fonction pour mettre à jour la liste des OUs
function Refresh-OUList {
    $comboBoxOUParent.Items.Clear()
    $comboBoxOUParent.Items.AddRange((Get-OUList))
    $comboBoxOUDelete.Items.Clear()
    $comboBoxOUDelete.Items.AddRange((Get-OUList))
}