FROM eclipse-temurin:21-jre

ARG PACK_URL
ARG PACK_VERSION
ENV PACK_VERSION=${PACK_VERSION}

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/server

RUN set -eu; \
    echo ">>> Telechargement $PACK_URL"; \
    curl -fL --retry 3 --retry-all-errors -A "Mozilla/5.0" "$PACK_URL" -o /tmp/pack.zip; \
    ls -lh /tmp/pack.zip; \
    unzip -q /tmp/pack.zip -d /tmp/p; \
    rm /tmp/pack.zip; \
    src=/tmp/p; \
    if [ "$(ls -1 /tmp/p | wc -l)" = "1" ] && [ -d "/tmp/p/$(ls -1 /tmp/p)" ]; then \
      src="/tmp/p/$(ls -1 /tmp/p)"; \
    fi; \
    cp -a "$src"/. /opt/server/; \
    rm -rf /tmp/p; \
    echo ">>> Contenu du pack :"; ls -la /opt/server; \
    \
    NF=""; \
    if [ -f variables.txt ]; then \
      NF=$(grep -hoE '(MODLOADER|NEOFORGE)_VERSION=[^ ]*' variables.txt | head -1 | cut -d= -f2 | tr -d '\r"' || true); \
    fi; \
    if [ -z "$NF" ] && [ -f server-setup-config.yaml ]; then \
      NF=$(grep -oE 'neoforge-[0-9][0-9.]*' server-setup-config.yaml | head -1 | cut -d- -f2 || true); \
    fi; \
    if [ -z "$NF" ] && [ -d libraries/net/neoforged/neoforge ]; then \
      NF=$(ls -1 libraries/net/neoforged/neoforge | head -1 || true); \
    fi; \
    if [ -z "$NF" ]; then \
      NF=$(ls -1 | grep -oE 'neoforge-[0-9][0-9.]*' | head -1 | cut -d- -f2 || true); \
    fi; \
    if [ -z "$NF" ]; then \
      echo "!!! Version NeoForge introuvable. Fichiers a la racine :"; ls -la; \
      for f in variables.txt server-setup-config.yaml; do \
        [ -f "$f" ] && { echo "--- $f ---"; cat "$f"; }; \
      done; \
      exit 1; \
    fi; \
    echo ">>> NeoForge $NF"; \
    \
    if [ ! -f "libraries/net/neoforged/neoforge/$NF/unix_args.txt" ]; then \
      curl -fL --retry 3 \
        "https://maven.neoforged.net/releases/net/neoforged/neoforge/${NF}/neoforge-${NF}-installer.jar" \
        -o installer.jar; \
      java -jar installer.jar --installServer; \
      rm -f installer.jar installer.jar.log; \
    fi; \
    rm -f startserver.sh startserver.bat start.sh start.bat run.bat; \
    echo "$NF" > /opt/server/.neoforge-version; \
    echo ">>> Mods : $(ls -1 mods 2>/dev/null | wc -l)"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown -R 1000:1000 /opt/server

USER 1000:1000
WORKDIR /data
EXPOSE 25565
ENTRYPOINT ["/entrypoint.sh"]
