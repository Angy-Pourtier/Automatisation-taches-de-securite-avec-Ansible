#!/bin/bash

# Définir un fichier de log
LOG_FILE="connect_login.log"

# Fonction pour enregistrer les messages dans le log
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
    echo "$1"
}

# Réinstaller xdotool pour X11 (facultatif, au cas où vous êtes sous X11)
log "Réinstallation de xdotool..."
sudo apt update && sudo apt install -y xdotool >> $LOG_FILE 2>&1

# Réinstallation de ydotool pour Wayland
log "Réinstallation de ydotool..."
sudo apt update && sudo apt install -y libudev-dev libevdev-dev libhidapi-dev pkg-config scdoc cmake >> $LOG_FILE 2>&1
if [ -d "ydotool" ]; then
    log "Suppression de l'ancienne installation de ydotool..."
    sudo rm -rf ydotool >> $LOG_FILE 2>&1
fi

log "Clonage du dépôt ydotool..."
git clone https://github.com/ReimuNotMoe/ydotool.git >> $LOG_FILE 2>&1
cd ydotool || exit 1
log "Compilation et installation de ydotool..."
cmake . >> $LOG_FILE 2>&1 && make >> $LOG_FILE 2>&1 && sudo make install >> $LOG_FILE 2>&1
cd ..

# Vérifier si le service ydotoold est démarré, sinon le démarrer
log "Vérification du service ydotoold..."
if ! pgrep -x "ydotoold" > /dev/null; then
    log "Le service ydotoold n'est pas démarré. Démarrage en cours..."
    sudo nohup ydotoold > /dev/null 2>&1 &
    sleep 2
else
    log "Le service ydotoold est déjà démarré. Redémarrage..."
    sudo pkill ydotoold
    sudo nohup ydotoold > /dev/null 2>&1 &
    sleep 2
fi

# Fixer les permissions du socket
log "Fixation des permissions du socket ydotool..."
sudo chmod 666 /tmp/.ydotool_socket >> $LOG_FILE 2>&1

# Vérifier que le socket est accessible
if [ ! -S /tmp/.ydotool_socket ]; then
    log "Échec : le socket ydotoold n'est pas accessible." >&2
    exit 1
fi

