#!/bin/sh
set -e
cd /data

NF="$(cat /opt/server/.neoforge-version)"

# (Re)deploie le pack quand la version de l'image change.
# Le monde, les configs serveur et les whitelist/ops sont preserves.
if [ "$(cat .pack-version 2>/dev/null || true)" != "$PACK_VERSION" ]; then
  echo ">> Deploiement ATM10 $PACK_VERSION (NeoForge $NF)"
  for f in server.properties whitelist.json ops.json banned-players.json banned-ips.json; do
    [ -f "$f" ] && cp "$f" "/tmp/$f"
  done
  rm -rf mods libraries config defaultconfigs kubejs packmenu
  # On copie entree par entree : cp -a sur /data/. echoue car la racine
  # du volume appartient a root et le conteneur tourne en UID 1000.
  for item in /opt/server/* /opt/server/.[!.]*; do
    [ -e "$item" ] || continue
    cp -a "$item" /data/
  done
  for f in server.properties whitelist.json ops.json banned-players.json banned-ips.json; do
    [ -f "/tmp/$f" ] && cp "/tmp/$f" "$f"
  done
  echo "$PACK_VERSION" > .pack-version
  echo ">> Pack deploye : $(ls -1 mods | wc -l) mods"
fi

# Valeurs par defaut au tout premier demarrage seulement.
if [ ! -f server.properties ]; then
  cat > server.properties <<EOF
motd=ATM10 @ k8s
allow-flight=true
max-tick-time=-1
view-distance=8
simulation-distance=6
difficulty=normal
online-mode=true
EOF
fi

echo "eula=true" > eula.txt

exec java -Xms"${MEMORY:-10G}" -Xmx"${MEMORY:-10G}" ${JAVA_OPTS:-} \
  @"libraries/net/neoforged/neoforge/${NF}/unix_args.txt" nogui
