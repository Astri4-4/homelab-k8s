FROM eclipse-temurin:21-jre

ARG PACK_URL
ARG PACK_VERSION
ENV PACK_VERSION=${PACK_VERSION}

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/server

# Telecharge le Server Pack ATM10 et installe NeoForge au build.
# La version de NeoForge est lue dans variables.txt du pack : rien a coder en dur.
RUN set -eux; \
    curl -fsSL "$PACK_URL" -o /tmp/pack.zip; \
    unzip -q /tmp/pack.zip -d /tmp/p; \
    rm /tmp/pack.zip; \
    src=/tmp/p; \
    if [ "$(ls -1 /tmp/p | wc -l)" = "1" ] && [ -d "/tmp/p/$(ls -1 /tmp/p)" ]; then src="/tmp/p/$(ls -1 /tmp/p)"; fi; \
    cp -a "$src"/. /opt/server/; \
    rm -rf /tmp/p; \
    NF=$(grep -hoE '^[A-Z_]*(MODLOADER|NEOFORGE)_VERSION=.*' variables.txt 2>/dev/null | head -1 | cut -d= -f2 | tr -d '\r"'); \
    if [ -z "$NF" ]; then echo "NeoForge version introuvable dans variables.txt"; cat variables.txt || true; exit 1; fi; \
    echo "NeoForge $NF"; \
    curl -fsSL "https://maven.neoforged.net/releases/net/neoforged/neoforge/${NF}/neoforge-${NF}-installer.jar" -o installer.jar; \
    java -jar installer.jar --installServer; \
    rm -f installer.jar installer.jar.log; \
    rm -f startserver.sh startserver.bat run.bat server-setup-config.yaml; \
    echo "$NF" > /opt/server/.neoforge-version

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown -R 1000:1000 /opt/server

USER 1000:1000
WORKDIR /data
EXPOSE 25565
ENTRYPOINT ["/entrypoint.sh"]
