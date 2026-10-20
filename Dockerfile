FROM rust:1.98.1-slim-trixie AS builder
WORKDIR /export

RUN apt update && apt install -y --no-install-recommends \
    wget \
    build-essential

RUN cargo install --locked zellij --root /export/ \
    && mv /export/bin/zellij /export/zellij \
	&& rm -rf /export/bin \
    && wget https://github.com/helix-editor/helix/releases/download/25.07.1/helix_25.7.1-1_amd64.deb -P /export/

FROM rust:1.98.1-slim-trixie
WORKDIR /workspace

COPY --from=builder /export /tmp

RUN mv /tmp/zellij /usr/local/bin/zellij \
    && apt update && apt install -y --no-install-recommends \
    git \
    build-essential \
    man \
    curl \
    /tmp/helix_25.7.1-1_amd64.deb \
    && rm -rf /tmp/helix_25.7.1-1_amd64.deb /var/lib/apt/lists/* \
    && rustup component add rust-analyzer

RUN git config --global credential.helper '!f() { echo "username=x-access-token"; echo "password=${GITHUB_TOKEN}"; }; f' \
    && git config --global init.defaultBranch main

RUN echo "scroll_mode_sync false" >> /root/.config/zellij/config.kdl

CMD ["/usr/local/bin/zellij", "attach", "-c", "main", "options", "--default-shell", "bash", "--default-mode", "locked"]
