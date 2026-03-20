#!/bin/sh
set -eu

#get vars, valitation



MODE=${MODE:-backup}
echo "Modus: ${MODE}"

for var in PBS_REPOSITORY PBS_PASSWORD PBS_FINGERPRINT  PBS_ENCRYPTION_PASSWORD BACKUP_ID BACKUP_NS; do
  eval val=\${$var:-}
  if [ -z "$val" ]; then
    echo "ERROR: $var is not set" >&2
    exit 1
  fi
done

case "$MODE" in
#----------------------------------------------------
  backup)
#### backup: wichitg ist auch, dass die compose.yml mit pinned image versions mit ins backup kommt 

## include mount points
INCLUDE_DEVS=""
for dir in /backup/*/; do
  INCLUDE_DEVS="$INCLUDE_DEVS --include-dev $dir"
done

# 1. backup funktion ausfueren
  proxmox-backup-client backup \
    "${BACKUP_ID}.pxar:/backup" \
    --ns "$BACKUP_NS" \
    --backup-id "$BACKUP_ID" \
    --keyfile /key/enc.key \
    $INCLUDE_DEVS


# 2. snapshot namen ermitteln --> get last snapshot
# 3. get all mount names -> /backup/*
# 4. note update mit volume names

;;
#----------------------------------------------------
#### restore:
  restore)
  # latest snapshot ermitteln
  # get id name. wenn leer: print avaiable names
  # get snapshot name. wenn leer: print snapshots -> optionen oder leer defualts zu latest
  SNAPSHOT=$(proxmox-backup-client snapshot list \
    --ns "$BACKUP_NS" \
    --output-format json \
    | jq -r '[.[] | select(."backup-id" == "'"$BACKUP_ID"'")] | sort_by(."backup-time") | .[-1]."backup-time" | todate')

  echo "Restoring snapshot: host/${BACKUP_ID}/${SNAPSHOT}"

    # befehl ausfueren 
  proxmox-backup-client restore \
    "host/${BACKUP_ID}/${SNAPSHOT}" \
    "${BACKUP_ID}.pxar" /backup/ \
    --ns "$BACKUP_NS" \
    --keyfile /key/enc.key \
    --allow-existing-dirs true
;;
#----------------------------------------------------
  *)
    echo "ERROR: Unknown Mode '$MODE'. Use: backup, restore" >&2
    exit 1
    ;;
esac

# sleep infinity
