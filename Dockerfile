# Stages:
#   toolchain  aarch64 cross-compiler and the arm64 libraries libwallaby links against
#   dev        toolchain + dev tools + agent CLIs, used by .devcontainer/
#   builder    toolchain + the `kipr` build user; the default target (keep it last)

# Debian 13 provides python3.13-dev, the Python version the Wombat ships.
FROM debian:13.6 AS toolchain

RUN dpkg --add-architecture arm64 \
    && apt-get update \
    && apt-get install -y \
        binutils \
        build-essential \
        cmake \
        doxygen \
        g++-aarch64-linux-gnu \
        gcc \
        gcc-aarch64-linux-gnu \
        git \
        libx11-dev:arm64 \
        make \
        python3.13-dev:arm64 \
        swig \
        wget \
    && rm -rf /var/lib/apt/lists/*


FROM toolchain AS dev

# file: check the architecture of built binaries (`file build/libkipr.so`).
# gnupg: lets VS Code forward the host GPG agent for signed commits.
# bubblewrap, socat: the agent CLIs' command sandboxes.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bubblewrap \
        ca-certificates \
        curl \
        fd-find \
        file \
        fish \
        fzf \
        gnupg \
        jq \
        openssh-client \
        ripgrep \
        socat \
    && ln -s "$(command -v fdfind)" /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 code \
    && useradd --uid 1000 --gid 1000 --create-home --shell /usr/bin/fish code

USER code

# Agent state lives in named volumes; a new volume inherits this ownership.
# CLAUDE_CONFIG_DIR also moves ~/.claude.json inside the volume.
ENV CLAUDE_CONFIG_DIR=/home/code/.claude \
    CODEX_HOME=/home/code/.codex \
    PATH=/home/code/.local/bin:$PATH

# The Codex installer keeps its binaries under CODEX_HOME. Point it elsewhere
# for the install so the binaries stay in the image, not in the shared volume.
# The installers also write state into the config dirs; empty them, because
# Docker copies that content into a newly created volume.
RUN mkdir -p "$CLAUDE_CONFIG_DIR" "$CODEX_HOME" \
    && curl -fsSL https://claude.ai/install.sh | bash \
    && claude --version \
    && curl -fsSL https://chatgpt.com/codex/install.sh \
        | CODEX_HOME=/home/code/.local/share/codex CODEX_NON_INTERACTIVE=true sh \
    && codex --version \
    && find "$CLAUDE_CONFIG_DIR" "$CODEX_HOME" -mindepth 1 -delete

WORKDIR /home/code


FROM toolchain AS builder

RUN groupadd --gid 1000 kipr \
    && useradd --uid 1000 --gid 1000 kipr

USER kipr:kipr
