# USER_DOC.md — User Documentation

This document explains how to use and manage the Inception stack as an end user or administrator.

---

## What Services Are Running?

The stack runs 3 services, each in its own container:

| Service | What it does | Port |
|---|---|---|
| **Nginx** | Web server, handles HTTPS, entry point for all traffic | 443 |
| **WordPress** | The CMS (website + admin panel), runs via PHP-FPM | internal only (9000) |
| **MariaDB** | Database, stores all WordPress content | internal only (3306) |

Only **Nginx** is reachable from outside. WordPress and MariaDB are only accessible internally between containers.

---

## Starting the Project

```bash
make
```

This will:
1. Build all Docker images from scratch
2. Start all 3 containers in the correct order
3. Run the setup scripts (WordPress install, DB creation)

Wait a few seconds after running — MariaDB and WordPress need time to initialize on first boot.

---

## Stopping the Project

```bash
# stop containers (keeps data)
make down

# stop and remove everything including volumes and images
make fclean
```

> `make down` keeps your data safe. `make fclean` wipes everything.

---

## Accessing the Website

Open your browser and go to:

```
https://amsaq.42.fr
```

If you are running this locally (not on a real server), add this line to your `/etc/hosts`:

```
127.0.0.1   amsaq.42.fr
```

> The site uses a **self-signed SSL certificate** — your browser may show a security warning. This is expected. Click "Advanced" and proceed.

---

## Accessing the Admin Panel

Go to:

```
https://amsaq.42.fr/wp-admin
```

Login with:
- **Username**: value of `WP_ADMIN_USER` in your `.env` file
- **Password**: content of `secrets/password.txt`

---

## Credentials — Where to Find Them

| Credential | Location |
|---|---|
| WordPress admin user | `WP_ADMIN_USER` in `.env` |
| WordPress admin email | `WP_ADMIN_EMAIL` in `.env` |
| WordPress admin password | `secrets/password.txt` |
| Database name | `MYSQL_DATABASE` in `.env` |
| Database user | `MYSQL_USER` in `.env` |
| Database password | `secrets/password.txt` |

> Never share or commit `secrets/password.txt` or `.env`. They are listed in `.gitignore`.

---

## Checking That Services Are Running

### Quick status check

```bash
docker ps
```

You should see 3 containers running: `nginx`, `wordpress`, `mariadb`.

### Check container health

```bash
docker inspect --format='{{.Name}} → {{.State.Health.Status}}' mariadb
```

Expected output:
```
/mariadb → healthy
```

### Check logs

```bash
# nginx logs
docker logs nginx

# wordpress logs
docker logs wordpress

# mariadb logs
docker logs mariadb
```

### Test the website is responding

```bash
curl -k https://amsaq.42.fr
```

You should get HTML back. `-k` skips SSL verification for self-signed certs.

---

## Common Issues

**Site not loading?**
- Check containers are running: `docker ps`
- Check nginx logs: `docker logs nginx`
- Make sure port 443 is not used by another service on your host

**Database error on WordPress?**
- Check mariadb health: `docker inspect mariadb`
- Check mariadb logs: `docker logs mariadb`

**Password wrong?**
- The same password in `secrets/password.txt` is used for MariaDB root, MariaDB user, and WordPress admin
