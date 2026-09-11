# Web Portal

The portal is a **static Next.js page** with two blocks: links to every repository of
the `xlnux` organization (animated with `XDecryptedText`) and a short English
explanation that this repository serves artifacts for X Linux. There is no navbar,
theme or forms: the site is a single route (`/`) that is statically exported and
deployed to GitHub Pages together with the packages.

## Stack

- **Next.js 16** with the App Router (`next ^16.2.9`), React 19, TypeScript (strict).
- **Tailwind CSS 4** (`@tailwindcss/postcss`) with the X palette
  (`app/globals.css`).
- **@xscriptor/xcomponents** — `XDecryptedText`, the decrypt animation for the links,
  with `animateOn="view"` so it runs on load.

The `@xscriptor/xcomponents` library does not ship its Tailwind utilities, so
`app/globals.css` has an `@source` directive that scans
`node_modules/@xscriptor/xcomponents/dist`.

`package.json` still keeps dependencies the page no longer uses (`three`,
`react-markdown`, `react-hook-form`); they can be removed in a separate cleanup.

## Source layout

| Path | Role |
|---|---|
| `app/layout.tsx` | Root layout: metadata and Anonymous Pro font. |
| `app/page.tsx` | The only route: animated links to the `xlnux` repos and the explanation. |
| `app/globals.css` | Tailwind entry, X palette, `@source` and font. |

## Static export and deployment

`next.config.mjs` keeps `output: 'export'` and `basePath: '/x-repo'`. The
`.github/workflows/build.yml` workflow ("Deploy Website to GitHub Pages") is
triggered manually (`workflow_dispatch`):

1. Runs `npm ci && npm run build` (static export to `./out`).
2. Checks that `x.db` and an `x-release` tarball exist under `public/`.
3. Uploads `./out` with `upload-pages-artifact` and deploys it with `deploy-pages`.

The workflow **does not build packages**. Packages are built locally and committed
(see [publishing.md](publishing.md)); the export copies all of `public/` into `out/`,
so the `[x]` repository and the `.xp` endpoint are published on the same site:

- `out/repo/x86_64/...` → `https://xlnux.github.io/x-repo/repo/x86_64/...`
- `out/x/x86_64/...` → `https://xlnux.github.io/x-repo/x/x86_64/...`
- `public/.nojekyll` prevents Jekyll processing.

Publishing a package is still: rebuild the repo locally, commit the new files under
`public/` and run the deploy workflow once.
