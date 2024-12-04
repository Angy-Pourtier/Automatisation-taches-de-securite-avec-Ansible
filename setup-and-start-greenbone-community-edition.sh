#!/bin/bash

set -e
RELEASE="22.4"

installed() {
    if ! [ -x "$(command -v $1)" ]; then
        echo "$1 n'est pas disponible. Veuillez l'installer."
        exit 1
    fi
}

# Vérifier les dépendances
installed curl
installed docker
installed docker-compose

echo "Utilisation des conteneurs Greenbone Community $RELEASE"

# Télécharger docker-compose.yml si absent
if [ ! -f "docker-compose-22.4.yml" ]; then
    echo "Téléchargement de docker-compose..."
    curl -f -O https://greenbone.github.io/docs/latest/_static/docker-compose-22.4.yml
else
    echo "docker-compose.yml déjà présent."
fi

# Téléchargement des conteneurs
echo "Téléchargement des conteneurs Greenbone Community $RELEASE"
docker compose -f docker-compose-22.4.yml -p greenbone-community-edition pull
echo

# Démarrage des conteneurs principaux
echo "Démarrage des conteneurs Greenbone Community $RELEASE"
docker compose -f docker-compose-22.4.yml -p greenbone-community-edition up -d
echo

# Configuration du mot de passe admin
password=$1
docker compose -f docker-compose-22.4.yml -p greenbone-community-edition \
    exec -u gvmd gvmd gvmd --user=admin --new-password=$password

# Synchronisation des données
echo "Synchronisation des flux de données..."
docker compose -f docker-compose-22.4.yml -p greenbone-community-edition pull notus-data vulnerability-tests scap-data dfn-cert-data cert-bund-data report-formats data-objects
docker compose -f docker-compose-22.4.yml -p greenbone-community-edition up -d notus-data vulnerability-tests scap-data dfn-cert-data cert-bund-data report-formats data-objects


