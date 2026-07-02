# Deljinder Beanlands — Portfolio Website

A personal portfolio site for **Deljinder Beanlands**, web developer & designer.

> **Status:** early prototype. Content is placeholder while the structure and design are being finalized.

## Overview

A fast, static portfolio showcasing projects, an about section, and contact + newsletter forms.

- **Front end:** static HTML/CSS/JS (prototype). Migrating to **Astro** (static site generation) — no SSR.
- **Content:** **Strapi 5** headless CMS (hosted on DigitalOcean). The site fetches About, Projects, and Social links from Strapi, automatically switching between local and production based on where it runs:
  - Local: `http://localhost:1337`
  - Production: `https://strapi-first-38bva.ondigitalocean.app`
  - Falls back to placeholder content if Strapi is unreachable.
- **Contact & newsletter:** submit to the **HubSpot** Forms API.

## Project structure

- `index.html` — the site (single self-contained file: HTML, CSS, and JS inline).
- `docs/Portfolio-Website-Strategy.md` — full strategy & phased build plan.
- `Open in Chrome.bat` — Windows helper to open the site in Chrome regardless of the default browser.

## Running locally

Open `index.html` directly in a browser, or serve the folder:

```bash
npx serve .
```

For live CMS data, run Strapi locally on port `1337`; otherwise the site uses the production API or placeholder content.

## Deployment

Intended for **DigitalOcean App Platform** as a static site connected to this repository. Pushing to the default branch can trigger an automatic redeploy.

## Roadmap

The full phased plan (design system, Astro migration, CMS wiring, SEO, launch) lives in [`docs/Portfolio-Website-Strategy.md`](docs/Portfolio-Website-Strategy.md).
