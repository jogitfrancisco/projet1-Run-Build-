# projet1-Run-Build-
Migration et déploiement sécurisé des packages

Objectif du projet: 

- Migrer un code/sw de github vers bitbucket 
- Automatiser ce code avec jenkins dans un premier temps depuis Nexus qui recevoira les packages 
- Sauvegarder les secrets qui Ansible va utiliser pour recuperer les packages de Nexus via vault de Hashicorp 
- Deployer les packages sur les environnements windows et linux

# Exigences
- bash
- Jenkins v.xx
- Ansible v.xx
- Harshicorp Vault v.xx
- Nexus v.xx
- cassandra v.xx

# Utilisation
``` 
sudo ./cassandra.sh 
```
