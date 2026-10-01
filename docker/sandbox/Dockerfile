FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_BREAK_SYSTEM_PACKAGES=1

RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-pip python3-venv \
      nodejs npm \
      curl wget git jq ca-certificates \
      build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /work

WORKDIR /work