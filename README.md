# WordPress + Nginx + MySQL + Docker 🐋


Olá, tudo bem?


Este projeto configura um servidor **WordPress** com **Nginx** e **MySQL** usando **Docker** e é executado via pipeline no GitHub Actions.


  - Inclui scripts para backup e restauração utilizando AWS S3. 


  - O objetivo é aprofundar meus conhecimentos em Docker e Nginx utilizando o WordPress como exemplo prático.

  
  - Projeto desenvolvido em uma EC2 t2.micro com Ubuntu. 

> Serão lançados 3 containers, um para cada serviço: **Wordpress**, **Nginx** e **MySQL**, orquestrados pelo **docker-compose.yml**.


---


## Como Rodar 🟢


### Opção 1: Execução Manual 1️⃣


#### Pré-requisitos:


- **Docker** e **Docker Compose** instalados.


  - Execute o `userdata.sh` localizado na pasta scripts, ou utilize-o como **User data** ao criar sua instância EC2.


#### Passos:


1. Clone o repositório:
```bash
git clone https://github.com/nolascojoao/s3-wordpress-backup-restore.git \
&& cd s3-wordpress-backup-restore
```


2. Suba os containers com o comando:
```bash
docker compose up -d
```


3. Verifique os containers em execução:
```bash
docker ps
```


4. Acesse o Wordpress no seu navegador através do IP da sua instância EC2. ✅

  
  > Para derrubar os containers, use:
  >
  >`docker compose down`


---


### Opção 2: Execução Automática com GitHub Actions 2️⃣


#### Pré-requisitos:


- **Fork** do repositório.


- **Instância EC2** com Ubuntu ou Debian, com permissão de acesso 0.0.0.0 na porta 22 para SSH e na porta 80 para HTTP.
> ⚠️ Use 0.0.0.0 apenas para ambientes de estudo e testes e evite deixar as portas expostas por longos períodos.


- **Variáveis secretas** configuradas no GitHub Actions:


  - `EC2_HOST` (Endereço IP da sua instância EC2)


  - `EC2_SSH_KEY` (Chave privada SSH para acessar a instância EC2)


  - `EC2_USER` (Usuário da instância, ex: `ubuntu` ou `admin`)


#### Passos:


1. Faça um **fork** deste repositório para a sua conta no GitHub.


2. Crie as variáveis secretas no repositório (GitHub Settings → Secrets).


3. Faça uma alteração no código e execute um **git push**. Isso irá disparar o workflow do GitHub Actions, que:


    - Instalará as dependências necessárias na EC2 (como Docker, Docker Compose e AWS CLI).


     - Subirá o servidor automaticamente utilizando as imagens definidas no arquivo **docker-compose.yml**.


5. Após a execução do workflow, o servidor estará rodando. ✅


> Acesse o **WordPress** no **IP da sua instância EC2** para completar a configuração. ⚙️


---


## Como Fazer Backup 💾


#### Pré-Requisitos:


- **Bucket S3** deve estar criado para armazenar os backups do WordPress.


- **AWS CLI** deve estar instalada e configurada com credenciais que tenham permissão de acesso ao seu bucket S3.


#### Passos:


1. Insira a URL do seu bucket S3 no arquivo `backup_wordpress.sh`:
```bash
S3_BUCKET="joaonolasco-wp-backup"
```


2. Execute o script de backup:
```bash
sudo ./backup_wordpress.sh
```
  > Certifique-se de dar permissão de execução ao script:
  >
  > `chmod +x scripts/backup_wordpress.sh`


3. Consulte os logs de backup:
  ```bash
  cat /opt/backups/logs/backup.log
  ```


4. Verifique os arquivos armazenados no seu bucket S3:


<div align="center">
  <img src="https://github.com/user-attachments/assets/2b676f48-989a-4718-8508-75f0255e921d"/>
</div>


---

 
## Como Fazer Restauração 🔄


#### Pré-Requisitos:


- **Bucket S3** com arquivos de backup disponíveis.
- **AWS CLI** deve estar instalada e configurada com credenciais que tenham permissão de acesso ao seu bucket S3.


#### Passos:


1. Edite a URL do bucket S3 no arquivo `restore_wordpress.sh`:
```bash
S3_BUCKET="joaonolasco-wp-backup"
```

2. Defina a data correspondente aos arquivos de backup no seu bucket S3:
> Escolha a data desejada descomentando a linha apropriada no script.
```bash
BACKUP_DATE=$(date +%Y%m%d)     # Data de hoje (padrão)
#BACKUP_DATE=20250112           # Substitua por uma data específica no formato YYYYMMDD
```


3. Execute o script de restauração:
```bash
sudo ./restore_wordpress.sh
```
  > Certifique-se de dar permissão de execução ao script:
  >
  > `chmod +x scripts/restore_wordpress.sh`


4. Consulte os logs de restauração:
  ```bash
  cat /opt/backups/logs/restore.log
  ```


5. Acesse o WordPress pelo navegador para verificar se a restauração do backup foi aplicada corretamente ao site.


---


## CronJob ⏰


> Você pode automatizar a execução do backup configurando um CronJob no seu sistema


#### Passos:


1. Edite o crontab com o comando:
```bash
sudo crontab -e
```


2. Adicione a seguinte linha para agendar a execução do backup:
```bash
15 15 * * * /home/ubuntu/s3-wordpress-backup-restore/scripts/backup_wordpress.sh
```
> Ajuste os horários conforme sua necessidade.


```plaintext
* * * * *  
| | | | |  
| | | | +----- Dia da semana (0 - 7) [Domingo = 0 ou 7]  
| | | +------- Mês (1 - 12)  
| | +--------- Dia do mês (1 - 31)  
| +----------- Hora (0 - 23)  
+------------- Minuto (0 - 59)
```


---


## Observação ℹ️


> O arquivo `docker-compose.yml` utiliza variáveis de ambiente para configurar os serviços. 


Essas variáveis estão definidas no arquivo `.env`, localizado na raiz do repositório. 


Atualmente, o `.env` contém credenciais genéricas projetadas exclusivamente para fins de teste e estudo. 


Essas credenciais podem ser alteradas diretamente no `.env` para se adequarem ao seu ambiente.


Por exemplo, no arquivo `.env` atual:  


- **Variáveis do WordPress** controlam a conexão com o banco de dados (`WORDPRESS_DB_HOST`, `WORDPRESS_DB_USER`, etc.).  


- **Variáveis do MySQL** incluem a senha do usuário root e informações para inicializar o banco de dados.


#### .env
> ⚠️ Em ambientes de produção, o arquivo `.env` deve ser mantido em sigilo e **nunca exposto em repositórios públicos**.
