#!/bin/bash

# Arrêter le script en cas d'erreur
set -e

# Fonction pour afficher un message d'état
log_message() {
    echo "----------------------------------"
    echo "$1"
    echo "----------------------------------"
}

# Étape 1 : Mise à jour des paquets
log_message "Mise à jour des paquets"
sudo apt update

# Étape 2 : Mise à niveau des paquets
log_message "Mise à niveau des paquets"
sudo apt upgrade -y

# Étape 3 : Installation d'Ansible
log_message "Installation d'Ansible"
sudo apt install -y ansible

# Étape 4 : Exécution du premier playbook
log_message "Exécution du playbook : preparation.yml"
sudo ansible-playbook -i inventory.ini preparation.yml

# Étape 5 : Exécution du second playbook
log_message "Exécution du playbook : openvas.yml"
sudo ansible-playbook -i inventory.ini openvas.yml

# Étape 6 : Exécution du troisième playbook
log_message "Exécution du playbook : update_openvas_db.yml"
ansible-playbook -i inventory.ini update_openvas_db.yml

log_message "Toutes les étapes ont été exécutées avec succès."

