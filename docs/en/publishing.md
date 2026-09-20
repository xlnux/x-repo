# Publishing a Package

Publishing to the `[x]` pacman repository is a **local build then commit** flow.
GitHub Actions never builds packages; it only deploys what is committed under
`public/` (see [web-portal.md](web-portal.md)).

The full cycle: local build -> `repo-add` -> `SHA256SUMS` -> PR -> Pages deploy.

## 1. Local build

Requirements: an Arch-like environment with `makepkg` and `repo-add` available.

### Package built from a PKGBUILD in this repo

Work on the package source, then build it inside its directory exactly as
`build-packages.sh` does:

```bash
cd packages/x-release      # or packages/x-dev
makepkg -cf --noconfirm
```

This produces a `.pkg.tar.zst` (e.g. `x-release-1.0-8-any.pkg.tar.zst`) inside the
package directory.

### External package (x-scripts)

`x-scripts` is built in the sibling `scripts` repo (its `PKGBUILD` lives at
`scripts/packaging/`), not here, and it ships the offline equisdots desktop
snapshot used by the installer. Build it there:

```bash
cd scripts/packaging && makepkg -f
```

`build-packages.sh` imports the resulting
`../scripts/packaging/x-scripts-*.pkg.tar.zst` automatically and removes it from the
build directory. You can also place the tarball directly in `public/repo/x86_64/`
before running the script. There is no `packages/x-scripts/` source directory in
this repo.

### Native .xp packages (xpm/xpkg path)

The `.xp` endpoint under `public/x/x86_64/` is out of scope for this flow: the
automated native workflow is disabled and kept for reference in
`docs/build-x-native-workflow.md`.

## 2. Regenerate the repository (repo-add)

From the repository root run:

```bash
./build-packages.sh              # builds x-release/x-dev + imports x-scripts + indexes
./build-packages.sh --index-only # skip the local builds (only import/index)
```

The script:

1. Rebuilds the configured PKGBUILD packages (`x-release`, `x-dev`) with `makepkg`
   unless `--index-only` is given.
2. Imports `../scripts/packaging/x-scripts-*.pkg.tar.zst` when present and copies the
   freshly built `x-release`/`x-dev` tarballs into `public/repo/x86_64/`, deleting
   only those build artifacts. The committed leftovers under `packages/xpm`,
   `packages/xpkg`, `packages/xfetch` and `packages/xtop` are not touched.
3. Rebuilds the pacman database from scratch from every tarball in the directory
   (this also drops entries for packages that no longer exist):

   ```bash
   repo-add -R x.db.tar.gz *.pkg.tar.zst
   cp x.db.tar.gz x.db
   cp x.files.tar.gz x.files
   sha256sum * > SHA256SUMS
   ```

Do not edit `x.db` or `SHA256SUMS` by hand; always regenerate them with this script
(contributing rules in `CONTRIBUTING.md` also forbid manual database edits).

## 3. Review and commit

Check what changed under `public/repo/x86_64/`:

```bash
git status
git diff --stat
```

Expected changes for a package update:

- the new `.pkg.tar.zst` (and removal of the replaced version),
- regenerated `x.db`, `x.db.tar.gz`, `x.files`, `x.files.tar.gz`,
- regenerated `SHA256SUMS`,
- the `PKGBUILD` change itself under `packages/`.

Commit the repository changes, for example:

```bash
git add packages/x-release public/repo/x86_64
git commit -m "publish x-release 1.0-8"
```

## 4. Pull request

Per `CONTRIBUTING.md` the contribution flow is fork, branch, pull request against the
`main` branch. Maintainers can also commit to a working branch and open the PR
directly. Merge to `main` once CI/validation passes.

## 5. Deploy to GitHub Pages

After the changes are on `main`, deploy the site so the new repository files go live:

1. Go to the **Actions** tab of `xlnux/x-repo`.
2. Run the **"Deploy Website to GitHub Pages"** workflow (`build.yml`) manually via
   `workflow_dispatch`.
3. The workflow runs `npm ci && npm run build` (static export of the Next.js site
   including everything from `public/`), sanity-checks that `x.db` and an
   `x-release` tarball exist, then uploads `./out` to GitHub Pages.

The updated packages are now served at:

- `https://xlnux.github.io/x-repo/repo/x86_64/` (pacman `[x]` repo)

### Caveats

- Do not run two Pages deployment workflows at once; they would overwrite each
  other's deployment (a `pages` concurrency group is defined in `build.yml`, and
  `docs/build-x-native-workflow.md` warns the same for the native workflow, which is
  disabled).
- Keep the repository in sync with its consumers: `x-release` and `x-dev` are
  installed from this repo during the X distro install, and `x-scripts` must match
  the payload revision expected by the installer.
