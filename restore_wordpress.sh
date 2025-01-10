#!/bin/bash

set -e

# Carrega variáveis do .env
set -a
source .env
set +a

#BACKUP_DATE=$(date +%Y%m%d)	# Data de hoje (padrão)
BACKUP_DATE=20250110		# Substitua por uma data específica no formato YYYYMMDD
BACKUP_DIR="/opt/backups"

FILES_BACKUP="wordpress_files_backup_${BACKUP_DATE}.tar.gz"
DB_BACKUP="wp_db_backup_${BACKUP_DATE}.sql"

S3_BUCKET="joaonolasco-wp-backup"

WP_VOLUME_PATH="/var/lib/docker/volumes/s3-wordpress-backup-restore_wordpress_data/_data"
DB_VOLUME_PATH="/var/lib/docker/volumes/s3-wordpress-backup-restore_db_data/_data"

mkdir -p $BACKUP_DIR/logs

# Cria o .my.cnf dentro do container MySQL para permitir que o host se autentique com o banco de dados
if ! docker exec mysql test -f /root/.my.cnf; then
    echo -e "[client]\nuser=root\npassword=${MYSQL_ROOT_PASSWORD}" | docker exec -i mysql tee /root/.my.cnf > /dev/null
fi

# Restauração do banco de dados
aws s3 cp s3://$S3_BUCKET/$DB_BACKUP $BACKUP_DIR/$DB_BACKUP
sudo mv $BACKUP_DIR/$DB_BACKUP $DB_VOLUME_PATH
docker exec -i mysql mysql wp_db < $DB_VOLUME_PATH/$DB_BACKUP

# Restauração dos arquivos do WordPress
aws s3 cp s3://$S3_BUCKET/$FILES_BACKUP $BACKUP_DIR/$FILES_BACKUP
tar -xzvf $BACKUP_DIR/$FILES_BACKUP -C $WP_VOLUME_PATH

rm -f $DB_VOLUME_PATH/$DB_BACKUP
rm -f $BACKUP_DIR/$FILES_BACKUP

echo "Restauração do backup concluída!"
