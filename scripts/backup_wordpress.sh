#!/bin/bash

set -e

# Carrega variáveis do .env
set -a
source /home/ubuntu/s3-wordpress-backup-restore/.env
set +a

BACKUP_DIR="/opt/backups"
FILES_BACKUP="wordpress_files_backup_$(date +%Y%m%d).tar.gz"

DB_BACKUP="wp_db_backup_$(date +%Y%m%d).sql"
S3_BUCKET="joaonolasco-wp-backup"

WP_VOLUME_PATH="/var/lib/docker/volumes/s3-wordpress-backup-restore_wordpress_data/_data"

mkdir -p $BACKUP_DIR/logs

# Cria o .my.cnf dentro do container MySQL para permitir que o host se autentique com o banco de dados
if ! docker exec mysql test -f /root/.my.cnf; then
    echo -e "[client]\nuser=root\npassword=${MYSQL_ROOT_PASSWORD}" | docker exec -i mysql tee /root/.my.cnf > /dev/null
fi

# DB backup
docker exec mysql mysqldump wp_db > $BACKUP_DIR/$DB_BACKUP

# WordPress backup
tar -czvf $BACKUP_DIR/$FILES_BACKUP -C $WP_VOLUME_PATH .

# Envia backups para o S3
aws s3 cp $BACKUP_DIR/$DB_BACKUP s3://$S3_BUCKET/$DB_BACKUP
aws s3 cp $BACKUP_DIR/$FILES_BACKUP s3://$S3_BUCKET/$FILES_BACKUP

rm -f $BACKUP_DIR/$FILES_BACKUP
rm -f $BACKUP_DIR/$DB_BACKUP

echo "Backup completo e enviado para o S3!"
