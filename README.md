# docker-image-push

[![Build and push Docker image](https://github.com/arunherga/docker-image-push/actions/workflows/docker-build.yml/badge.svg)](https://github.com/arunherga/docker-image-push/actions/workflows/docker-build.yml)

A GitHub Actions pipeline that builds a Docker image and publishes it to the
GitHub Container Registry on every push to `main` and on every version tag.

The application in this repo is deliberately trivial — a one-line Python script.
It exists so the pipeline has something real to build. **The pipeline is the
point.**

## What it does

- Builds the image with BuildKit for **`linux/amd64` and `linux/arm64`**
- Publishes to **`ghcr.io/arunherga/docker-image-push`**
- Builds on pull requests but **never publishes from one**, so unreviewed code
  cannot reach the registry
- Caches layers between runs, so unchanged dependencies aren't rebuilt
- Attaches **build provenance and an SBOM** to the published image
- Cancels an in-flight build when a newer commit lands on the same branch

## Image tags

Tags are derived automatically by
[`docker/metadata-action`](https://github.com/docker/metadata-action):

| Event | Tags produced |
| --- | --- |
| Push to `main` | `latest`, `main`, `sha-<commit>` |
| Push of tag `v1.2.3` | `1.2.3`, `1.2`, `sha-<commit>` |
| Pull request | `pr-<number>` — built, not pushed |

`latest` only ever moves on the default branch. Every build is also addressable
by its full commit SHA, so a deploy can pin an exact image and roll back to one.

## Setup

**None.** Publishing uses the `GITHUB_TOKEN` that Actions provides to every run,
scoped by the workflow's own `permissions:` block. There is no registry password
to store, and no `DOCKER_USERNAME` / `DOCKER_PASSWORD` secret to rotate.

Packages published this way are private by default. To make the image publicly
pullable, open the package under **Profile → Packages → docker-image-push →
Package settings** and change its visibility.

## Pulling the image

```bash
docker pull ghcr.io/arunherga/docker-image-push:latest
docker run --rm ghcr.io/arunherga/docker-image-push:latest
```

## Building locally

```bash
docker build -t docker-image-push .
docker run --rm docker-image-push
```

## Reusing this in another repo

Copy [`.github/workflows/docker-build.yml`](.github/workflows/docker-build.yml)
into the target repo. It needs no edits — `images:` is derived from
`${{ github.repository }}`, so it publishes under whatever repo it lands in.
The repo needs a `Dockerfile` at its root, and its default branch should be
`main` (or adjust the `branches:` filter).

## Layout

```
.
├── .github/workflows/docker-build.yml   the pipeline
├── Dockerfile                           runs as a non-root UID
├── .dockerignore
└── app.py                               placeholder workload
```
