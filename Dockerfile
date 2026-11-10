FROM rust:1.98.1-slim-trixie
WORKDIR /workspace
EXPOSE 22

RUN apt update && apt install -y --no-install-recommends \
    git \
    build-essential \
    man \
    curl \
    openssh-server \
    && curl -L -o /tmp/helix_25.7.1-1_amd64.deb https://github.com/helix-editor/helix/releases/download/25.07.1/helix_25.7.1-1_amd64.deb \
    && apt install -y --no-install-recommends \
    /tmp/helix_25.7.1-1_amd64.deb \
    && rm -rf /tmp/helix_25.7.1-1_amd64.deb \
    && cargo install --locked zellij \
    && rustup component add rust-analyzer \
    && ssh-keygen -A

RUN rm -rf /var/lib/apt/lists/*

COPY ./docker/* /tmp

RUN mkdir -p /usr/local/share/zellij/layouts/ /root/.config/zellij/ \
    && mv /tmp/entrypoint.sh /usr/local/bin/entrypoint.sh \
    && mv /tmp/ssh.conf /etc/ssh/sshd_config.d/00-custom.conf \
    && mv /tmp/workspace.kdl /usr/local/share/zellij/layouts/workspace.kdl \
    && zellij setup --dump-config > /root/.config/zellij/config.kdl \
    && cat /tmp/zellij_cfg.kdl >> /root/.config/zellij/config.kdl \
    && cat /tmp/bashrc_mod >> /root/.bashrc \
    && rm -f /tmp/zellij_cfg.kdl /tmp/bashrc_mod

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
