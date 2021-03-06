#!/bin/bash
set -e
DIR=`dirname $0`
DIR=`readlink -f $DIR`
cd $DIR

#Variables names to be modified
SITE_NAME=ARG
LOCAL_HOST="${SITE_NAME}.local.com"
DISTANT_USER=__DISTANT_USER__
LOCAL_USER=__LOCAL_USER__
SITE_BASE=TOKENSITEBASE
DB_NAME=DISTANT_DB_NAME
DB_USERNAME=DISTANT_DB_USER
DB_PASSWORD=DISTANT_PASSWD_DB
DB_HOST=DISTANT_SERVER
LOCAL_DB_NAME=$DB_NAME
LOCAL_DB_PASSWORD=LOCAL_PASSWD_DB
LOCAL_DB_USER=LOCALDBUSERTOKEN
RSYNC=/usr/bin/rsync
FILES_FOLDER=${SITE_BASE}

# TODO : root -> dev
SSH_USER="${DISTANT_USER}@${DB_HOST}"


function die
{
        echo "$@" >&2
        exit 1
}

for TESTDIR in $DIR/.. $SITE_BASE
do
        [ -d "$TESTDIR" ] || die "Directory $TESTDIR does not exist"
done



# copy db
echo "${SSH_USER}"
/usr/bin/ssh $SSH_USER "cd /home/$DISTANT_USER; mysqldump -u$DB_USERNAME -p$DB_PASSWORD $DB_NAME >dbtmp.sql"
TMP_DIR=TMP_PATH
mkdir -p ${TMP_DIR}
/usr/bin/scp $SSH_USER:/home/$DISTANT_USER/dbtmp.sql ${TMP_DIR}/dbtmp.sql
mysql -u$LOCAL_DB_USER -p$LOCAL_DB_PASSWORD $LOCAL_DB_NAME <${TMP_DIR}/dbtmp.sql

# To be changed when needed
