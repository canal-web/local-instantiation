#!/bin/bash
set -e
function die
{
    echo "$@" >&2
    exit 1
}

# Variables to get from command line
[ ! -z "$1" ] || die "Site name should be given as first argument"

# TYPE=$2
VAR_FILES="variables/*"
CMS=false
ORIGINAL_GIT=false
OPTIND=1

# Manage flags
while getopts ":c:o:" opt; do
 case $opt in
   c)
     CMS=$OPTARG
     ;;
   o)
     ORIGINAL_GIT=$OPTARG
     ;;
   \?)
     die "Invalid option: -$OPTARG"
     ;;
   :)
     die "Option -$OPTARG requires an argument."
     ;;
 esac
done

shift $((OPTIND-1))
SITE_NAME=$1
SOURCE_NAME=$SITE_NAME

# Change source name if provided
if [[ $ORIGINAL_GIT != false ]]; then
    SOURCE_NAME=$ORIGINAL_GIT
fi

# Define default variables (you must duplicate the files with a "local." prefix to rewrite them)
for f in $VAR_FILES; do
    if [[ $f != *local* ]]; then
        source $f
    fi
done


# Include local variables
for f in $VAR_FILES; do
    if [[ $f == *local* ]]; then
        source $f
    fi
done

# Create needed directories
LOCAL_DIR="${PATH_LOCAL_SITES}${SITE_NAME}${SUFFIX_SITENAME}/"
if [[ ! -d $LOCAL_DIR ]]; then
    sudo mkdir -p "${LOCAL_DIR}web"
    sudo chown -R ${LOCAL_USER}.${LOCAL_GROUP} ${LOCAL_DIR}
    sudo chmod g+w ${LOCAL_DIR}
    mkdir -p "${LOCAL_DIR}logs"
    mkdir -p "${LOCAL_DIR}bin"
    echo "Directories have been created."
fi

# Redir fake domain name
HOST="127.0.0.1 ${SITE_NAME}.local.com"
if  ! grep -Fxq "$HOST" "/etc/hosts"; then
    sudo cp /etc/hosts /etc/hosts.backup
    sudo bash -c "echo $HOST >> /etc/hosts"
    echo "Host file is now up-to-date"
fi

# Handle Apache Configuration for the new website
if [[ ! -f "/etc/apache2/sites-enabled/${SITE_NAME}.conf" ]]; then
    cat "templates/apache.conf" | sed -e "s/SITENAME/${SITE_NAME}/g" -e "s,LOCALDIR,${LOCAL_DIR},g" > "templates/${SITE_NAME}.conf"
    sudo mv "templates/${SITE_NAME}.conf" "/etc/apache2/sites-available/${SITE_NAME}.conf"
    sudo ln -s "/etc/apache2/sites-available/${SITE_NAME}.conf" "/etc/apache2/sites-enabled/${SITE_NAME}.conf"
fi
# Ready? Go!
sudo service apache2 reload
echo "The apache conf file is set up, now reloading apache service..."

# But we also need to create a database
mysql -u${LOCAL_USER_DB} -p${LOCAL_PASSWD_DB} -e "CREATE DATABASE IF NOT EXISTS $SITE_NAME;"
echo "Database created."

# And generate the get db script!
cat "templates/get_db_dist.bash" | sed \
-e "s,ARG,${SITE_NAME}," \
-e "s,LOCAL_USER,${LOCAL_USER}," \
-e "s,TOKENSITEBASE,${LOCAL_DIR}web," \
-e "s,DISTANT_PASSWD_DB,${DISTANT_PASSWD_DB}," \
-e "s,LOCAL_PASSWD_DB,${LOCAL_PASSWD_DB}," \
-e "s,LOCALDBUSERTOKEN,${LOCAL_USER_DB}," \
-e "s,DISTANT_SERVER,${DISTANT_SERVER}," \
-e "s,DISTANT_DB_NAME,${SOURCE_NAME}," \
-e "s,DISTANT_DB_USER,${SOURCE_NAME}," \
-e "s,TMP_PATH,${TMP_PATH}," \
 > "${LOCAL_DIR}bin/get_db_dist.bash"
chmod +x "${LOCAL_DIR}bin/get_db_dist.bash"
# Add specific instructions for CMS
if [[ $CMS != false && -f "templates/${CMS}/specific.sh" ]]; then
    cat "templates/${CMS}/specific.sh" >> "${LOCAL_DIR}bin/get_db_dist.bash"
fi

echo "Please check the generated get_db script."

# Git clone
git clone ${DISTANT_USER}@${DISTANT_SERVER}:/var/git/${SOURCE_NAME} ${LOCAL_DIR}web/


# Call instructions for a specific CMS
if [[ $CMS != false && -f "cms/${CMS}.sh" ]]; then
    source "cms/${CMS}.sh"
fi

${LOCAL_DIR}bin/get_db_dist.bash

cd ${LOCAL_DIR}web && $COMPOSER update
echo "The end."
