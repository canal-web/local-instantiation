# Création d'instances locales
Permet d'installer un site sur sa machine depuis un serveur distant de manière automatisée

## Installation

- Récupérer les fichiers avec `git clone git@github.com:canal-web/local-instantiation.git` ou en téléchargeant le zip.
- Copier les fichiers se situant dans le dossier `variables` et les renommer en les préfixant de `local.`, modifier le contenu en conséquence.

## Utilisation
```
./instance_locale.sh nomdusite
```

Si le site est fait sous un des CMS présents dans le dossier `cms` : 

```
./instance_locale.sh -c magento nomdusite
```

Pour un copier un site qui utilise un repository commun à d'autres : 

```
./instance_locale.sh -c magento -o repo_original nomdusite
```
**ATTENTION : le nom du site à dupliquer doit toujours être le dernier paramètre passé**

## Ajout d'un CMS

- Ajouter un fichier appelé `nomducms.sh` dans le dossier `cms` et mettre dedans tout ce qui est spécifique au cms (comme la création du fichier de connexion à la BDD).
- Mettre le gabarit du fichier de connexion à la BDD du cms dans `templates/nomducms`
- Pour ajouter des fonctionnalités spécifiques au CMS lors de la création du fichier de récupération de la base, ajouter un fichier `specific.sh` dans `templates/nomducms`
