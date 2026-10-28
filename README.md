# HTL Tag der offenen Tür 2026

This project is a small Gleam web app for security challenges. It serves the landing page and challenge-specific tasks locally.

## Run locally

```bash
gleam run
```

Then open:

```text
http://localhost:8000
```

## Run with Docker

```bash
docker build -t htl-hl .
docker run --rm -p 8000:8000 htl-hl
```

The app exposes port 8000.

## Project structure

- src/ — Gleam application source
- priv/static/ — static HTML/CSS/JS assets
- test/ — project tests
- Dockerfile — container build definition