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
EXPOSE 22

COPY --from=builder /export /tmp

RUN mv /tmp/zellij /usr/local/bin/zellij \
    && apt update && apt install -y --no-install-recommends \
    git \
    build-essential \
    man \
    curl \
    openssh-server \
    /tmp/helix_25.7.1-1_amd64.deb \
    && rm -rf /tmp/helix_25.7.1-1_amd64.deb /var/lib/apt/lists/* \
    && rustup component add rust-analyzer \
    && ssh-keygen -A

COPY ./build/entrypoint.sh /usr/local/bin/entrypoint.sh

COPY ./build/bashrc_mod /tmp/bashrc_mod
RUN cat /tmp/bashrc_mod >> /root/.bashrc \
    && rm -f /tmp/bashrc_mod

COPY ./build/ssh.conf /etc/ssh/sshd_config.d/00-custom.conf

COPY ./build/zellij_cfg.kdl /tmp/zellij_cfg.kdl
RUN mkdir -p /root/.config/zellij \
    && zellij setup --dump-config > /root/.config/zellij/config.kdl \
    && cat /tmp/zellij_cfg.kdl >> /root/.config/zellij/config.kdl \
    && rm -f /tmp/zellij_cfg.kdl

COPY ./build/workspace.kdl /usr/local/share/zellij/layouts/workspace.kdl

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
