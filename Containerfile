FROM docker.io/library/debian:trixie-slim AS builder
RUN apt-get update \
  && apt-get install -y --no-install-recommends wget ca-certificates \
  && wget -qO /usr/share/keyrings/proxmox-archive-keyring.gpg \
    "https://enterprise.proxmox.com/debian/proxmox-archive-keyring-trixie.gpg" \
  && echo "Types: deb\nURIs: http://download.proxmox.com/debian/pbs-client\nSuites: trixie\nComponents: main\nSigned-By: /usr/share/keyrings/proxmox-archive-keyring.gpg" \
      > /etc/apt/sources.list.d/pbs-client.sources \
  && apt-get update \
  && apt-get install -y --no-install-recommends proxmox-backup-client-static

# --- Stage 2: runtime --- #

FROM docker.io/library/alpine:3
RUN apk add --no-cache jq
COPY --from=builder /usr/bin/proxmox-backup-client /usr/local/bin
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# ENTRYPOINT ["/bin/sh"]
# ENTRYPOINT ["sleep", "infinity"]
ENTRYPOINT ["entrypoint.sh"]
