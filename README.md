# Rust Development Environment (Zellij + Helix)

Docker-based Rust development environment with Zellij and Helix.

## Setup

1. Place your public SSH key in the project root as `ssh_key.pub`.
2. Optionally configure `.env` (SSH port, Git credentials).
3. Build and start:

```bash
docker compose up -d
```

## Configuration

Edit `.env` to set:

- **SSH port** — defaults to `2222` if not specified.
- **Git credentials** — user name, email and token.

## Workspace

Files in `./workspace` are synced live with the container.

## Notes

- After changing the SSH port or Git credentials, run:

  ```bash
  docker compose up -d --force-recreate
  ```

- After replacing the SSH key, restart the container:

  ```bash
  docker compose restart
  ```
