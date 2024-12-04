#!/bin/bash

# Vérification de l'état du conteneur
echo "Vérification de l'état du conteneur..."
container_status=$(sudo docker ps -q --filter "name=greenbone-community-edition-gvmd-1")

if [ -z "$container_status" ]; then
  echo "Le conteneur n'est pas en cours d'exécution."
  exit 1
else
  echo "Le conteneur est déjà en cours d'exécution."
fi

# Vérification de l'utilisateur gvmuser dans le conteneur
echo "Vérification de l'utilisateur gvmuser dans le conteneur..."
user_check=$(sudo docker exec -i greenbone-community-edition-gvmd-1 id -u gvmuser)
if [ -z "$user_check" ]; then
  echo "L'utilisateur gvmuser n'existe pas dans le conteneur."
  exit 1
else
  echo "Utilisateur gvmuser vérifié dans le conteneur."
fi

# Vérification du répertoire temporaire pour gvmuser
echo "Vérification du répertoire temporaire pour gvmuser..."
temp_dir_check=$(sudo docker exec -i greenbone-community-edition-gvmd-1 ls -ld /home/gvmuser/scan_tmp)
if [ -z "$temp_dir_check" ]; then
  echo "Le répertoire /home/gvmuser/scan_tmp n'existe pas, création du répertoire."
  sudo docker exec -i greenbone-community-edition-gvmd-1 mkdir -p /home/gvmuser/scan_tmp
else
  echo "Répertoire temporaire pour gvmuser : /home/gvmuser/scan_tmp"
fi

# Création du fichier XML pour la cible
echo "Création du fichier XML de la cible..."
target_file="/home/gvmuser/scan_tmp/target.xml"
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<create_target>
  <name>MyTarget</name>
  <hosts>192.168.56.111</hosts>
  <port_list id=\"33d0cd82-57c6-11e1-8ed1-406186ea4fc5\"/>
</create_target>" | sudo docker exec -i greenbone-community-edition-gvmd-1 tee $target_file > /dev/null

# Vérification du fichier XML dans le conteneur
echo "Vérification du fichier XML dans le conteneur..."
sudo docker exec -i greenbone-community-edition-gvmd-1 cat $target_file

# Vérification de l'existence du socket gvmd...
echo "Vérification de l'existence du socket gvmd..."
socketpath="/run/gvmd/gvmd.sock"
if [ ! -S "$socketpath" ]; then
  echo "Le fichier de socket $socketpath n'existe pas."
  exit 1
else
  echo "Socket trouvé à : $socketpath"
fi

# Connexion via gvm-cli en utilisant le protocole GMP et socketpath
echo "Création de la cible via gvm-cli..."
sudo docker exec -u gvmuser -i greenbone-community-edition-gvmd-1 gvm-cli --protocol GMP --socket "$socketpath" --gmp-username admin --gmp-password admin --xml-file="$target_file" --command="create_target"

# Vérification de la création de la cible
echo "Vérification de la création de la cible..."
target_id=$(sudo docker exec -u gvmuser -i greenbone-community-edition-gvmd-1 gvm-cli --protocol GMP --socket "$socketpath" --gmp-username admin --gmp-password admin --command="get_targets" | grep "MyTarget" | awk '{print $1}')
if [ -z "$target_id" ]; then
  echo "Erreur lors de la création de la cible. ID de la cible non trouvé."
  exit 1
else
  echo "Cible créée avec succès. ID de la cible : $target_id"
fi

# Lancement du scan
echo "Lancement du scan..."
sudo docker exec -u gvmuser -i greenbone-community-edition-gvmd-1 gvm-cli --protocol GMP --socket "$socketpath" --gmp-username admin --gmp-password admin --command="start_task --target-id=$target_id"

echo "Scan lancé avec succès."

