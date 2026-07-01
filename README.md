*This project has been created as part of the 42 curriculum by amsaq.*

---

# Inception

## Description

Inception is a system administration project from the 1337 school curriculum. The goal is to set up a small infrastructure using Docker, where each service runs in its own container built from scratch — no pre-built images from Docker Hub allowed.

The stack hosts a fully functional WordPress website with:
- **Nginx** — the only entry point, handles HTTPS with TLS 1.3
- **WordPress + PHP-FPM** — runs the CMS
- **MariaDB** — stores all the WordPress data

All containers communicate through a private Docker network, and all data is persisted using bind-mount volumes on the host machine. Secrets (like passwords) are managed securely using Docker Secrets, never hardcoded.

### Design Choices

**Why Docker?**
Each service is isolated in its own container. This makes the stack modular, reproducible, and easy to manage. If one service crashes, only that container is affected — not the whole system.

**Why TLS 1.3 only?**
Older TLS versions (1.0, 1.1) have known vulnerabilities. Enforcing TLS 1.3 ensures the connection is always encrypted with the most secure protocol available.

**Why WP-CLI?**
Instead of going through the browser-based WordPress installer every time, WP-CLI lets us automate the full installation inside the container script — no manual steps needed.

---

### Virtual Machines vs Docker

| | Virtual Machine | Docker |
|---|---|---|
| **Isolation** | Full OS per VM | Shares host kernel |
| **Size** | Several GB | Few MB |
| **Boot time** | Minutes | Seconds |
| **Use case** | Full OS isolation needed | Running isolated services |

VMs emulate entire hardware + OS. Docker containers share the host kernel and only package the app and its dependencies. Docker is much lighter and faster for running microservices like this project.

---

### Secrets vs Environment Variables

| | Secrets | Environment Variables |
|---|---|---|
| **Where stored** | File, mounted at `/run/secrets/` | `.env` file or `environment:` block |
| **Visible in `docker inspect`?** | No | Yes |
| **Risk if exposed** | Low — file not in image | High — readable in image layers |
| **Use case** | Passwords, tokens | Non-sensitive config (domain, usernames) |

In this project, the database password is passed via Docker Secrets. Config like `MYSQL_DATABASE`, `DOMAIN_NAME` is passed via `.env`.

---

### Docker Network vs Host Network

| | Docker Network (bridge) | Host Network |
|---|---|---|
| **Isolation** | Containers are isolated | Container shares host's network stack |
| **Container DNS** | Containers talk by name | Not available |
| **Security** | Isolated | Exposed to host network |
| **Use case** | Multi-container apps | Specific performance/debugging needs |

This project uses a custom bridge network called `inception`. All 3 containers join it and communicate by container name (e.g. `mariadb`, `wordpress`) — never by IP. The host machine can only reach Nginx on port 443.

---

### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|---|---|---|
| **Managed by** | Docker | You (host path) |
| **Location on host** | `/var/lib/docker/volumes/` | Any path you choose |
| **Portability** | Easier to move | Tied to host path |
| **Control** | Less direct | Full control over host folder |
| **Use case** | Managed persistent storage | Dev, direct host access needed |

This project uses **bind mounts** so the data lives at a known path on the host (`/home/amsaq/data/`), making it easy to inspect and back up.

---

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- A Linux host (or VM)
- `make` available

### Setup

1. Clone the repository:
```bash
git clone https://github.com/amsaq/inception.git
cd inception
```

2. Create the secrets file:
```bash
mkdir -p secrets
echo "yourpassword" > secrets/password.txt
```

3. Create the `.env` file (see `.env.example` for required variables):
```bash
cp .env.example .env
# edit .env with your values
```

4. Create host data directories:
```bash
mkdir -p /home/amsaq/data/wordpress
mkdir -p /home/amsaq/data/mariadb
```

5. Build and run the project:
```bash
make
```

6. Visit: `https://amsaq.42.fr` (add to `/etc/hosts` if testing locally)

### Stop the project

```bash
make down
```

### Clean everything

```bash
make fclean
```

---

## Resources

### Documentation

- [Docker official docs](https://docs.docker.com/)
- [Docker Compose docs](https://docs.docker.com/compose/)
- [Nginx docs](https://nginx.org/en/docs/)
- [MariaDB docs](https://mariadb.com/kb/en/)
- [WP-CLI docs](https://wp-cli.org/)
- [WordPress Codex](https://codex.wordpress.org/)
- [TLS 1.3 - RFC 8446](https://www.rfc-editor.org/rfc/rfc8446)

### Articles & Tutorials

- [Docker networking explained](https://docs.docker.com/network/)
- [Docker Secrets overview](https://docs.docker.com/engine/swarm/secrets/)
- [PHP-FPM and Nginx setup](https://www.php.net/manual/en/install.fpm.php)
- [Understanding PID 1 in Docker](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)

### AI Usage

AI (Claude) was used during this project for the following:

- **Understanding concepts** — explaining what PID 1 means in Docker, schema of the project.
- **Debugging logic** — explaining why the MariaDB script starts mysqld twice and what the wait loop actually does - foreground and background.
- **Config explanation** — understanding the Nginx `server {}` block, `try_files`, FastCGI params
