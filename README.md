# proxmox-backup-client OCI

Minimal container image with a statically linked `proxmox-backup-client` binary for backing up Docker volumes to a Proxmox Backup Server.

There's no official image from Proxmox, so this is a good excuse to learn how to package a standalone binary into a minimal OCI image and ship it across systems. Along the way: multi-stage builds, static linking, non-root containers, POSIX shell scripting, and CI/CD with GitHub Actions + GHCR.

## Versioning

Image tags follow the bundled `proxmox-backup-client` version. For example, image tag `3.3.2` ships with `proxmox-backup-client` version `3.3.2`. Use `latest` to always get the most recent build.

## How it works

The container starts, backs up everything mounted under `/backup/`, and exits. Each subdirectory becomes a separate `.pxar` archive named after the directory.

```
/backup/data/   -> data.pxar
/backup/config/ -> config.pxar
```

## Usage

Works with both Docker and Podman — just swap the command.

```bash
podman run --rm \
  -e PBS_REPOSITORY="backup@pbs!token@pbs.local:8007:datastore" \
  -e PBS_PASSWORD="secret" \
  -e PBS_FINGERPRINT="AA:BB:CC:..." \
  -e BACKUP_ID="my-service" \
  -v /path/to/enc.key:/key/enc.key:ro \
  -v my-data-volume:/backup/data:ro \
  ghcr.io/OWNER/proxmox-backup-client:3.3.2
```

```bash
docker run --rm \
-e PBS_REPOSITORY="backup@pbs!token@pbs.local:8007:datastore" \
-e PBS_PASSWORD="secret" \
-e PBS_FINGERPRINT="AA:BB:CC:..." \
-e BACKUP_ID="my-service" \
-v /path/to/enc.key:/key/enc.key:ro \
-v my-data-volume:/backup/data:ro \
ghcr.io/OWNER/proxmox-backup-client:3.3.2
```

### Environment variables

| Variable          | Required | Description                                |
| ----------------- | -------- | ------------------------------------------ |
| `PBS_REPOSITORY`  | yes      | PBS connection string                      |
| `PBS_PASSWORD`    | yes      | PBS user password or API token secret      |
| `PBS_FINGERPRINT` | yes      | TLS fingerprint of the PBS server          |
| `BACKUP_ID`       | no       | Backup ID (defaults to container hostname) |

### Volume mounts

| Path             | Description                 |
| ---------------- | --------------------------- |
| `/key/enc.key`   | Encryption key (read-only)  |
| `/backup/<name>` | Data to back up (read-only) |

## Building

```bash
docker build -t proxmox-backup-client .
# or
podman build -t proxmox-backup-client .
```

## Upcoming

- **Cron mode** - container stays running with a built-in scheduler for periodic backups
- **Restore** - restore snapshots back to volumes
- **Notifications** - webhook/email alerts on backup success or failure
- **Multi-arch** - ARM64 support
