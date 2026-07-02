# Portfolio Website — Strategy & Build Plan

**Prepared for:** Violet
**Date:** July 2, 2026
**Role I'm playing:** Designer · Developer · Strategist
**Source of truth:** [Product Backlog (Google Doc)](https://docs.google.com/document/d/1WYC6R0Dp5WAKcirm5i5YwyovUYITZqbWZQJ_MrerUXQ/edit)

---

## 1. Executive summary

You want a **professional, design-led portfolio** that makes a strong first impression, showcases your work to hiring managers, captures leads through a contact form, and is easy to keep up to date without touching code. The backlog is clear and mature — it already thinks about content management, lead routing, compliance, and SEO, which is unusually complete for a portfolio brief.

Based on your direction, this is scoped as a **developer / tech portfolio**, built as a **statically generated site** — no server-side rendering. The front end is **Astro**, which outputs plain static HTML/CSS served from a CDN; a **Strapi 5** headless CMS holds your content so you can add and edit projects yourself; and **HubSpot** is the destination for every lead the contact form generates. When you publish in Strapi, a build step bakes fresh static HTML automatically — you get flat-file simplicity *and* self-service editing, with none of the runtime complexity of SSR.

This document is the plan we'll build against. It covers positioning, the site structure, the page-by-page content, the design direction, the technical architecture, SEO and privacy, and a phased roadmap. At the end there's a matrix showing exactly how each backlog item is satisfied, plus a short list of the things I need from you to start building.

---

## 2. Positioning & goals

A portfolio has to do a job. Yours has two primary jobs and two supporting ones.

**Primary job 1 — Get hired.** A hiring manager or recruiter lands on the site, understands within seconds what you do and how well you do it, browses a few projects deep enough to judge your ability, and leaves with a way to reach you. Everything on the site should shorten the path from "who is this?" to "I want to talk to this person."

**Primary job 2 — Generate leads.** For freelance or contract work, a potential client should be able to see relevant work and get in touch in one motion. That's why the contact form pipes into HubSpot — so an inbound lead becomes a trackable contact, not a lost email.

**Supporting job 3 — Be effortlessly current.** You should never have to ask a developer to add a project. Strapi gives you a private admin panel where you write once and the site updates itself.

**Supporting job 4 — Be discoverable & compliant.** The site should rank when someone searches your name or your specialty, and it should handle personal data (yours and your visitors') in a way that's legally clean.

**How we'll measure success:** clarity of first impression (a stranger can describe what you do in one sentence), depth of engagement (visitors reach project detail pages), and conversion (qualified contact-form submissions landing in HubSpot).

---

## 3. Audiences

Three audiences come straight from your backlog, and the design serves all three without compromise.

The **hiring manager / recruiter** is skimming, often on mobile, often with ten other tabs open. They need the headline, the proof, and the contact button — fast. We optimize the home page and project cards for this person.

The **potential client / lead** wants relevance and trust. They're asking "can this person solve *my* problem?" We serve them with outcome-focused case studies and a frictionless, always-reachable contact path.

**You, the editor.** You're an audience too — of the admin panel. The CMS has to be pleasant enough that keeping the site fresh feels like a two-minute task, not a chore.

---

## 4. Information architecture (site map)

```
Home  (/)
│  ├─ Hero: who you are + primary CTA
│  ├─ Featured projects (3–4 pulled live from CMS)
│  ├─ Skills / tech stack
│  ├─ Short "about" teaser
│  └─ Contact CTA band
│
├─ Projects  (/projects)
│     └─ Project detail  (/projects/[slug])   ← one per project, from CMS
│
├─ About  (/about)
│     └─ Bio, background, experience, downloadable résumé
│
├─ Contact  (/contact)
│     └─ Contact form → HubSpot
│
├─ (Optional) Blog / Writing  (/blog, /blog/[slug])   ← great for SEO
│
└─ Legal
      ├─ Privacy Policy  (/privacy)
      └─ (Cookie notice / consent banner, site-wide)
```

A **persistent, always-visible call-to-action** — the backlog's "sticky CTA that stays visible while scrolling" — lives in the header (a "Let's talk" / "Contact" button) and is reinforced by a floating action on long pages, so a visitor is never more than one click from reaching you.

---

## 5. Page-by-page plan

**Home.** The most important 600 pixels on the site. A tight hero: your name, a one-line statement of what you do and who you do it for, and the primary CTA. Below it, 3–4 featured projects pulled live from the CMS (you flag a project as "featured" in Strapi and it appears here automatically). Then a scannable skills/stack strip, a brief about teaser that links to the full About page, and a closing contact band. No walls of text.

**Projects (index).** A responsive grid of project cards — thumbnail, title, one-line summary, and the tech/tags. Optional filtering by tag (e.g. "React," "API," "data"). Every card links to its detail page.

**Project detail.** This is where hiring managers make their judgment, so it earns the most structure: the problem, your role, the approach, the tech used, the outcome/result, and a gallery or embed (live demo link, GitHub link, screenshots, or video). All of this is CMS-driven, so each project is as rich or as lean as you make it.

**About.** Your story, told for the two audiences: enough narrative to be human, enough substance to be credible. Experience highlights, the tools you work in, and a downloadable résumé (PDF). Links to GitHub, LinkedIn, etc.

**Contact.** A short form — name, email, and message, plus an optional "what's this about" dropdown to help you triage. On submit it posts to HubSpot (details in §6). Clear success and error states, spam protection, and a privacy line linking to the policy.

**Blog / Writing (optional but recommended).** The single highest-leverage thing you can add for SEO. Even a handful of technical posts dramatically increases the surface area you rank for and gives return visitors a reason to come back. CMS-driven, so it's just another content type in Strapi.

**Privacy Policy + consent.** A plain-language policy plus a lightweight consent banner (see §8).

---

## 6. Technical architecture (full stack)

The system is three cleanly separated pieces, built around **static generation** — content is baked into plain HTML at build time, so there is no server rendering pages at runtime.

```
   ┌─────────────────┐   content pulled AT BUILD TIME     ┌──────────────────┐
   │   Strapi 5 CMS  │   (REST/GraphQL, JWT-secured)      │   Astro          │
   │  (admin + API)  │  ───────────────────────────────▶  │  build step      │
   │                 │◀──── you log in to edit ──────      │  → static HTML   │
   └─────────────────┘                                     └────────┬─────────┘
          ▲    │ publish fires a webhook → rebuild                  │ deploy
          │ you (editor)                                            ▼
     admin panel                                          ┌──────────────────┐
                                                          │  CDN (flat files)│  ◀── visitors
                                                          └────────┬─────────┘
                                                                   │ contact form submit
                                                                   ▼
                                                          ┌──────────────────┐
                                                          │   HubSpot        │
                                                          │  (leads / CRM)   │
                                                          └──────────────────┘
```

### Front end — Astro (static output)

Astro is the right fit for your stated preference: it is HTML-first and ships **zero JavaScript by default**, producing plain static HTML/CSS that's served as flat files from a CDN. At build time Astro pulls your content from Strapi (via its first-party Strapi integration) and generates every page ahead of time — so visitors get pre-rendered HTML with excellent SEO and load speed, and there is **no runtime server to operate**. When you publish or edit a project in Strapi, a **webhook triggers an automatic rebuild**, and the updated site is live within about a minute — you never touch code.

Styling: **Tailwind CSS** for a consistent, maintainable design system, with a reusable component approach so cards, buttons, and layouts stay uniform. Fully responsive, mobile-first, dark-mode aware. Where a page needs a touch of interactivity (e.g. the project filter or a menu), Astro ships that small piece of JS in isolation rather than hydrating the whole page.

### CMS — Strapi 5

Strapi gives you a **private, secure admin panel** (JWT auth + role-based access control) where you add, edit, and delete content — directly satisfying the backlog's "add/modify/delete projects" and "secure admin interface" requirements. It exposes content over **REST and GraphQL APIs** that Astro consumes at build time (and that the current prototype consumes at runtime).

**Connection (live).** Your Strapi is deployed at `https://strapi-first-38bva.ondigitalocean.app` (production), with `http://localhost:1337` for local development. The site selects the base URL **automatically based on where it runs** — localhost or an opened file uses local Strapi; any deployed domain uses production (overridable via `window.STRAPI_URL`). Endpoints in use: `GET /api/about-me?populate=*`, `GET /api/projects1?populate=*`, and `GET /api/socialmedias?populate=*`. The prototype fetches these at runtime and falls back to placeholder content whenever Strapi is unreachable, so the site never looks broken. (The newsletter posts to HubSpot, not Strapi; `POST /api/subscribers` stays available if you later prefer to store subscribers in Strapi.)

**Action needed in Strapi (permissions + CORS).** From inspecting your live API: `about-me` is publicly readable, but `projects1` and `socialmedias` currently return **403 Forbidden**. In Strapi → **Settings → Users & Permissions → Roles → Public**, enable `find`/`findOne` for **Project** and **Social Media** (the newsletter no longer needs Strapi, since it posts to HubSpot — though you'd add `create` for **Subscriber** if you switch it back). Then add your deployed domain(s) to Strapi's **CORS** allow-list so the browser can call the API from the live site. Once those are on, real content flows in with no code change. Because those two collections are 403 right now, I couldn't read their exact field names — so the prototype maps them defensively (trying common names) and logs a sample item to the browser console; once they're readable I'll lock the mapping to your real fields.

Proposed content model:

- **Project** — title, slug, summary, body (rich text), role, tech tags (relation), outcome, cover image, gallery (media), live URL, repo URL, `featured` (boolean), date, SEO fields.
- **Tag / Tech** — name, slug (so projects can be filtered).
- **Author / Profile** — your bio, headshot, résumé file, social links (so the About page is also editable, not hard-coded).
- **Post** (if we do the blog) — title, slug, body, cover, tags, publish date, SEO fields.
- **Global settings** — site title, meta defaults, contact email, CTA text — so you can tweak site-wide copy without a deploy.

### Lead capture — HubSpot

Because the site is static (no server), the form still works cleanly — this does **not** force us back into SSR. Two implementation options, and I recommend the first:

1. **Custom form → HubSpot Forms Submission API (recommended).** We build the form in Astro with full control over design and validation, and POST submissions directly to HubSpot's Forms Submission API from the browser — which is exactly how HubSpot's own embed works, and uses your public portal + form ID (no secret exposed). Leads create/update a HubSpot contact. For spam protection we add a honeypot field and, if you want server-side filtering (rate limiting, hCaptcha/Turnstile verification), a **single serverless function** on Vercel/Netlify handles just that one endpoint — a tiny bit of serverless, still not SSR.
2. **Embedded HubSpot form.** Faster to stand up but less design control and it loads HubSpot's script client-side. Fine as a fallback.

Either way, leads land in HubSpot where you can set up notifications, workflows, and tracking.

**Connection status (now wired):** the contact form is connected to HubSpot via the Submission API — **portal `343409901`**, **form `bfbae00e-7995-4e7a-a6e4-4db7457a77e4`** (region `na3`). We POST directly from the browser to `api.hsforms.com` (no server, no secret), mapping the form's fields to HubSpot's `email`, `firstname`, and `message` (the "What's this about?" subject is folded into the message so we don't post a field the HubSpot form may not have). If the HubSpot form uses different internal field names, we adjust that mapping.

**Newsletter sign-up (new backlog item).** A footer newsletter form — email address only, plus a Subscribe button — is built and wired to **HubSpot** via the Forms Submission API (per your request). It currently reuses your contact form's ID (`bfbae00e-…`); the code exposes a separate `newsletterFormId` constant so you can drop in a **dedicated email-only HubSpot form** anytime. Caveat worth noting: if the reused form marks any field besides email as *required*, HubSpot will reject an email-only submission — so a dedicated newsletter form is recommended. (Strapi's `POST /api/subscribers` endpoint remains available if you ever want subscribers stored in Strapi instead.)

### Hosting & deployment

- **Front end:** Vercel or Netlify — both host static Astro output on a global CDN with automatic deploys and preview builds, on generous free tiers. Cloudflare Pages is another strong static host. A Strapi publish webhook triggers the rebuild automatically.
- **CMS:** Strapi Cloud (managed, least operational overhead) or a self-hosted option (Render / Railway / a small VPS) if you'd rather own it. Strapi needs a database — Postgres is the standard choice, included with the managed options.
- **Media:** Strapi handles uploads; for production we point it at cloud storage (e.g. Cloudinary or S3-compatible) so images are fast and durable.
- **Domain + SSL:** your custom domain with automatic HTTPS.

---

## 7. Design direction

For a developer portfolio, the design itself is a work sample — it signals taste and craft. The direction I'd propose:

**Clean, confident, and technical.** Generous whitespace, a strong typographic hierarchy (one distinctive display face for headings, a highly legible sans for body), and a restrained color palette — a neutral base with a single strong accent — so the *work* is the color on the page. Dark mode as a first-class citizen (developers expect it, and it photographs well).

**Motion with restraint.** Subtle scroll-triggered reveals and micro-interactions on cards and buttons to feel alive and modern, never so much that it slows the page or distracts. Respect `prefers-reduced-motion`.

**Proof-forward.** The layout should push real work — screenshots, live demos, metrics — above narrative. Hiring managers trust artifacts more than adjectives.

**Accessible by default.** WCAG-minded contrast, keyboard navigation, focus states, alt text (editable in the CMS), and semantic HTML. Accessibility is both the right thing and an SEO signal.

Before I build, I'll produce a small **design system** (colors, type scale, spacing, components) and a homepage concept so we lock the look before writing feature code.

---

## 8. SEO & discoverability

Directly satisfying the backlog's "optimized to appear in relevant searches."

Because Astro pre-renders every page to static HTML and ships almost no JavaScript, the fundamentals are strong out of the box (this is one of static generation's biggest advantages over SSR/SPA approaches). On top of that: per-page metadata driven from the CMS SEO fields (title, description, Open Graph / Twitter cards), a generated `sitemap.xml` and `robots.txt`, clean semantic markup with structured data (JSON-LD `Person` schema for you and `CreativeWork`/`Article` for projects and posts), fast Core Web Vitals (optimized images, minimal JS), and a canonical custom domain. The optional **blog** is the biggest lever for ranking beyond your own name — it's what lets you show up for "how I built X" style searches.

---

## 9. Privacy & compliance

The backlog calls out "privacy and personal info management" for legal compliance. Since you're contact-form collecting personal data and (via HubSpot) doing tracking, we'll handle this properly rather than as an afterthought.

Concretely: a plain-language **Privacy Policy** page (what we collect, why, where it goes — i.e. HubSpot — and how to request deletion); a **consent banner** for any analytics/tracking cookies, with the option to decline; explicit consent language on the contact form itself; and data minimization (we only ask for what we need). Given your `.vanarts.com` context you're likely Canada-based, so **PIPEDA** applies; if you'll take clients or visitors from the EU/UK, we'll make the consent flow **GDPR**-compliant too (opt-in, not opt-out). I'll draft the policy text as a starting point, but a final review by someone qualified is wise before launch — I'm not a lawyer, and this is informational, not legal advice.

---

## 10. Development roadmap (ordered by complexity)

The build is sequenced **from lowest to highest complexity**, so we lock the simple, high-value foundations first and only take on backend and integration work once the structure and design are settled. We start with **placeholder text and images** — the goal early on is the framework and structure, not final content — and swap in your real projects at Phase 4 with no structural change. Each phase is labeled with its complexity level.

**Phase 1 — Static structure & layout · Complexity: Low · ← we are here.** Build the skeleton of every page (Home, Projects, Project detail, About, Contact) as plain HTML/CSS with placeholder content, working navigation, responsive behavior, dark mode, and the persistent sticky CTA. No CMS, no backend, no build tooling. *Output: a clickable prototype of the whole site's structure you can react to.*

**Phase 2 — Design system & visual polish · Complexity: Low–Medium.** Turn the skeleton into a designed system: finalized typography, color palette, spacing scale, reusable components, tasteful motion/micro-interactions, and an accessibility pass. *Output: the look and feel locked.*

**Phase 3 — Interactivity · Complexity: Medium.** Project filtering by tag, mobile menu, theme toggle, and the contact form's UI with full client-side validation and success/error states — submission **stubbed** (not yet wired to HubSpot). *Output: the site feels real and interactive, still on placeholders.*

**Phase 4 — Port to Astro & real content · Complexity: Medium.** Move the static prototype into reusable Astro components and replace placeholders with your real projects, bio, images, and résumé. *Output: a maintainable, componentized static site with your actual content.*

**Phase 5 — Strapi CMS · Complexity: Medium–High · (started early — Strapi already deployed).** Your Strapi is live on DigitalOcean and the prototype already reads from it (about-me, projects, socials) with env-aware URL switching. Remaining: grant the Public role permissions and set CORS (see §6), confirm the projects/socials field mapping, model any missing fields, and — at Phase 4 — move these runtime fetches to Astro's build-time data loading plus the publish→rebuild webhook. *Output: you manage projects yourself; the site rebuilds automatically.*

**Phase 6 — HubSpot lead capture · Complexity: Medium · (started early — IDs received).** The contact form and the footer newsletter form are now connected to HubSpot's Submission API using your portal + form IDs. Remaining: confirm the contact form's field names match the mapping, create a dedicated email-only form for the newsletter, and optionally add server-side spam protection. *Output: real leads flow into HubSpot.*

**Phase 7 — SEO & compliance · Complexity: Medium.** Per-page metadata, `sitemap.xml`/`robots.txt`, JSON-LD structured data, the privacy policy page, and the consent banner. *Output: discoverable and compliant.*

**Phase 8 — Deployment & launch · Complexity: Medium–High.** Host the static output on Vercel/Netlify, connect your custom domain with HTTPS, add analytics, run a performance/Core Web Vitals pass, and hand off with a short editing guide. *Output: it's live and it's yours to run.*

Phases 1–3 need nothing from you and deliver a site you can click through. Phase 4 is the first point where real content matters, and Phase 6 is the only one that needs your HubSpot details — so those two are gated on you, and everything else can proceed in the meantime.

---

## 11. Backlog coverage matrix

Every item in your backlog, and where it's handled.

| Backlog item | How this plan satisfies it |
|---|---|
| Professional, design-oriented portfolio; strong first impression | §7 design direction + §5 home page; design-system-first approach |
| Persistent CTA visible while scrolling | §4 sticky header CTA + floating action on long pages |
| Editor can add / modify / delete projects to stay current | §6 Strapi CMS with Project content type |
| Backend managed by Strapi CMS, secure admin interface | §6 Strapi 5 admin panel, JWT auth, RBAC |
| Developer: authenticated backend access | §6 JWT + role-based access control |
| Hiring managers see projects & accomplishments in detail | §5 project detail pages (problem/role/approach/outcome) |
| Simple contact form | §5 + §6 contact page |
| Leads captured into HubSpot | §6 HubSpot Forms Submission API — **wired** (portal 343409901) |
| Newsletter sign-up (email only) in footer | §6 footer form → HubSpot — **wired** (reuses contact form; dedicated form recommended) |
| Privacy / personal-info legal compliance | §9 privacy policy, consent banner, PIPEDA/GDPR |
| SEO to appear in relevant searches | §8 metadata, sitemap, structured data, optional blog |

---

## 12. What I need from you — and when

Nothing is needed to start. **Phases 1–3 run entirely on placeholders**, so I can build the full structure, design, and interactivity without waiting on you. Here's when each input actually becomes relevant:

**Needed at Phase 4 (real content):**

1. **Your positioning in one line** — what you do and who for (e.g. "Full-stack developer building data-heavy web apps for startups"). If you're not sure, I can draft options.
2. **3–6 projects** — for each: title, the problem, what you did, the tech, the outcome/result, and any links (live site, repo) or images.
3. **About material** — a short bio, a headshot, your résumé (PDF), and links (GitHub, LinkedIn, etc.).

**Needed at Phase 6 (HubSpot — deferred, on your timeline):**

4. **HubSpot portal ID + form ID** (and a form set up in your HubSpot account). Until then the contact form is built and works as UI, with submission stubbed.

**Needed around Phase 8 (launch):**

5. **Domain** — do you already own one, and what is it?
6. **Hosting/CMS accounts** — a Vercel or Netlify account, and whether you prefer **Strapi Cloud** (managed) or **self-hosting** the CMS.

**Helpful anytime:** a couple of sites you love (portfolios or otherwise) so I can calibrate the design to your taste.

---

*This document is our living plan — as your needs sharpen, we update it. Ready when you are.*
