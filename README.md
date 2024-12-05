# Automatisation-taches-de-s-curit-avec-Ansible
Ce projet a pour objectif de renforcer la sécurité des systèmes Linux via l’automatisation des tâches de mise à jour, de configuration, de détection d’intrusion et de gestion des vulnérabilités à l’aide d’Ansible.


Prérequis
Matériel et logiciel :

    Système Linux (recommandé : Ubuntu 20.04 ou supérieur).
    Minimum : 2 CPU (4 CPU si possible) et 30 Go d’espace disque.


Dans un premier temps vous aller devoir pour récuperer ce git : 

    git clone https://github.com/Angy-Pourtier/Automatisation-taches-de-securite-avec-Ansible.git




Installation, Lancement et Mise en place de d'OpenVAS

1. Préparation de l’environnement :

Ensuite la premiere étape, va etre de mettre en place une machine a jour, puis d'installer, configurer openvas et de mettre a jour sa base de données.
Tout cela en lancant ce script : 

    sudo ./SCRIPT-1.sh


Ou lancez manuellement les étapes suivantes :

  sudo ansible-playbook -i inventory.ini preparation.yml

  Vous pouvez modifier ce playbook si vous souhaitez modifier le mot de passe : 
  sudo ansible-playbook -i inventory.ini openvas.yml
  
  ansible-playbook -i inventory.ini update_openvas_db.yml


Il est conseillez de continuer le projet pour laisser le temps au conteneur de mettre a jour la base de données ( 30min -1h30 ).

Pour la prochaine fois, pour le faire manuellement : 
Ouvrez Firefox, puis entrez cette url : http://localhost:9392.
Ensuite connectez vous avec les identifiants : admin - admin.
Aller dans l’onglet : Feed statuts
Visualiser l’état de la base de données et attendez que tout soit en current avant de creer de tache.



2. Configuration et Sécurisation

  Avant d'exécuter le prochain playbook, vous devez être sûr que vos machines sur lesquelles vous souhaitez mettre à jour les package sont accessibles en ssh et sont sur le même réseau que votre machine. Ensuite sur votre machine si ce n'est déjà fait taper ces commandes sur votre machine hôte : 

  ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
  
Entrez la passphrase que vous souhaitez.



Il vous faudra également créer un utilisateur sur les machines distantes, du même nom que votre utilisateur avec lequel vous exécutez le playbook.
Commande à faire pour créer l’utilisateur sur les autre machine : 

  sudo adduser [nom]
  sudo usermod -aG sudo [nom]



Faire ceci pour chaque machine si ce n'est déjà fait la première fois :
  ssh-copy-id -i ~/.ssh/id_rsa.pub utilisateur@ip_de_la_machine_distante



Avant d'éxécuter ce playbook modifier l'ip réseau dans le fichier pour qu'il mette a jour toute les machines sur ce réseau; Puis Exécuter le Playbook :

  ansible-playbook -i inventory.ini apply_patches.yml


Configurez la sécurité des services avec le playbook secure_config.yml : 

  sudo ansible-playbook -i inventory.ini secure_config.yml




3. Surveillance et Journalisation

Installez et configurez auditd pour la journalisation de la sécurité avec auditd_setup.yml :

  sudo ansible-playbook -i inventory.ini auditd_setup.yml

  

Cette étape peut prendre un certain temps selon le volume et le contenue de votre machine (1-2h). Il est également conseillé de le déployer en ssh pour éviter la fermeture de session automatique et engendrer des soucis. Installez et configurez AIDE pour vérifier l’intégrité des fichiers avec aide_setup.yml :

  sudo ansible-playbook -i inventory.ini aide_setup.yml



Et si tout est normal alors pour mettre à jour le fichier de base de donnée :

 	sudo aide --update
  sudo aide --config=/etc/aide/aide.conf --update



Configurez la centralisation des logs via configure_rsyslog.yml :

  sudo ansible-playbook -i hosts.ini configure_rsyslog.yml




4. Vérification de Conformité


Vérifiez les configurations système et droits d’accès avec compliance_check.yml :

  sudo ansible-playbook -i inventory.ini compliance_check.yml


  

Structure des Playbooks : 


preparation.yml : Préparation initiale du système (mises à jour, installation de Docker, etc.).
    
openvas.yml : Déploiement et lancement des conteneurs OpenVAS.
    
update_openvas_db.yml : Mise à jour de la base de données OpenVAS.
    
apply_patches.yml : Application des mises à jour système sur les machines distantes.
    
secure_config.yml : Renforcement des configurations système (pare-feu, désactivation des services inutiles).

auditd_setup.yml : Installation et configuration de auditd pour la journalisation.

aide_setup.yml : Installation et initialisation d’AIDE pour la vérification d’intégrité.

configure_rsyslog.yml : Configuration de rsyslog pour la gestion des logs.

compliance_check.yml : Vérification de conformité du système.



Auteur : Angy Pourtier
Licence : Open Source
