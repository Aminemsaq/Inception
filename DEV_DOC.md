# DEV_DOC.md — Developer Documentation

This document explains how to set up, build, and manage the Inception project from a developer perspective.

---

## Prerequisites

Make sure the following are installed on your machine:

```bash
docker --version        # Docker Engine
docker compose version  # Docker Compose v2
make --version          # GNU Make
```

Also needed:
- A Linux host or VM (the project is designed for Linux)
- `sudo` or root access (for creating host data directories)

---

## Project Structure

```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .env                        ← your config (gitignored)
├── .env.example                ← template to copy from
├── secrets/
│   └── password.txt            ← your password (gitignored)
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │       └── script.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            │   └── my.cnf
            └── tools/
                └── db-setup.sh
```

---

## Setting Up From Scratch

### 1. Clone the repo

```bash
git clone https://github.com/amsaq/inception.git
cd inception
```

### 2. Create the secrets file

```bash
mkdir -p secrets
echo "yourpassword" > secrets/password.txt
```

> This password is used for: MariaDB root, MariaDB user, WordPress admin.

### 3. Create the `.env` file

```bash
cp .env.example .env
```

Edit `.env` with your values:

```env
DOMAIN_NAME=amsaq.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=amsaq_user
MYSQL_USER2=amsaq2_user
WP_ADMIN_USER=amsaq_admin
WP_ADMIN_EMAIL=amsaq@student.42.fr
WP_USER_EMAIL=editor@student.42.fr
WP_USER2_EMAIL=author@student.42.fr
WP_VOLUME=/home/amsaq/data/wordpress
DB_VOLUME=/home/amsaq/data/mariadb
```

### 4. Create host data directories

These are the bind mount targets — MariaDB and WordPress will store their data here:

```bash
mkdir -p /home/amsaq/data/wordpress
mkdir -p /home/amsaq/data/mariadb
```

### 5. Add domain to `/etc/hosts` (local testing only)

```bash
echo "127.0.0.1 amsaq.42.fr" | sudo tee -a /etc/hosts
```

---

## Build and Launch

### Build and start everything

```bash
make
```

This runs `docker compose up --build -d` under the hood.

### What happens on first boot

```
mariadb container starts
  → creates database, user, secures root
  → healthcheck passes ✅

wordpress container starts (waits for mariadb healthy)
  → downloads WordPress
  → creates wp-config.php
  → installs WordPress (admin + 2nd user)
  → starts php-fpm ✅

nginx container starts (waits for wordpress)
  → loads SSL cert
  → listens on 443 ✅
```

---

## Makefile Commands

| Command | What it does |
|---|---|
| `make` | Build images and start all containers |
| `make up` | Start containers (no rebuild) |
| `make down` | Stop and remove containers (keeps volumes) |
| `make re` | Rebuild and restart everything |
| `make fclean` | Stop containers, remove images and volumes |
| `make logs` | Follow logs of all containers |
| `make ps` | Show running containers |

---

## Managing Containers

### Enter a container

```bash
# enter nginx
docker exec -it nginx bash

# enter wordpress
docker exec -it wordpress bash

# enter mariadb
docker exec -it mariadb bash
```

### Login to MariaDB

```bash
# from inside the mariadb container
docker exec -it mariadb bash
mysql -u root -p
```

Or directly:

```bash
docker exec -it mariadb mysql -u root -p
```

Useful SQL commands once inside:

```sql
SHOW DATABASES;
USE wordpress_db;
SHOW TABLES;
SELECT user, host FROM mysql.user;
EXIT;
```

### View logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb

# follow in real time
docker logs -f mariadb
```

### Check healthcheck status

```bash
docker inspect --format='{{.Name}} → {{.State.Health.Status}}' mariadb
```

---

## Where Data Is Stored

| Data | Inside container | On host machine |
|---|---|---|
| WordPress files | `/var/www/html` | `/home/amsaq/data/wordpress` |
| MariaDB database | `/var/lib/mysql` | `/home/amsaq/data/mariadb` |

Both are **bind mounts** — the container and the host share the same folder. You can inspect the data directly on your host at any time:

```bash
ls /home/amsaq/data/wordpress
ls /home/amsaq/data/mariadb
```

### How data persists

```
docker compose down   → containers removed, data on host stays ✅
docker compose up     → containers recreated, data loaded from host ✅
make fclean           → containers + images removed, data on host stays ✅
                        (unless you also manually delete /home/amsaq/data/)
```

> Data only disappears if you manually delete the host directories.

---

## SSL Certificate

The SSL certificate is self-signed and generated during the Nginx image build using `openssl`. It is stored inside the image at:

```
/etc/nginx/ssl/amsaq.crt
/etc/nginx/ssl/amsaq.key
```

To regenerate the cert, rebuild the nginx image:

```bash
docker compose build nginx
```

---

## Rebuilding a Single Service

```bash
# rebuild only mariadb
docker compose build mariadb
docker compose up -d mariadb

# rebuild only wordpress
docker compose build wordpress
docker compose up -d wordpress
```

---

## Network Overview

All containers are on the `inception` bridge network. They reach each other by container name:

| From | To | Address used |
|---|---|---|
| nginx | wordpress PHP-FPM | `wordpress:9000` |
| wordpress | mariadb | `mariadb:3306` |

No container except nginx has `ports` exposed to the host — MariaDB and WordPress are only reachable from within the Docker network.
