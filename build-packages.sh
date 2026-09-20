#!/usr/bin/env bash
set -euo pipefail

# Build the X packages locally and publish them to the local repo.
# Run from the x-repo root. Packages are committed and served via GitHub Pages.
#
# Usage: ./build-packages.sh [--index-only]
#
#   (no flags)    rebuild every PKGBUILD package (x-release, x-dev), import the
#                 sibling x-scripts build when present, regenerate the database.
#   --index-only  skip the local builds and only import/regenerate the repo
#                 (use when an external artifact changed, e.g. x-scripts).
#
# x-scripts lives in the sibling `scripts` repo (scripts/packaging/). When a
# fresh `../scripts/packaging/x-scripts-*.pkg.tar.zst` exists it is imported
# automatically and removed from the build directory.
#
# The native .xp endpoint (public/x) is out of scope here; see
# docs/build-x-native-workflow.md.

SELF="$(readlink -f "$0")"
cd "$(dirname "$SELF")"

REPO_DIR="public/repo/x86_64"
XPM_DIR="public/x/x86_64"
OUT_DIR="$(mktemp -d)"
trap 'rm -rf "$OUT_DIR"' EXIT

BUILD=1
for arg in "$@"; do
    case "$arg" in
        --index-only) BUILD=0 ;;
        -h|--help)
            sed -n '2,18p' "$SELF" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "build-packages: unknown argument '$arg' (see --help)" >&2
            exit 1
            ;;
    esac
done

# Packages built with PKGBUILD (makepkg) -> pacman .pkg.tar.zst
build_pkgbuild() {
    local dir="$1"
    echo "  - building $dir"
    (cd "packages/$dir" && makepkg -cf --noconfirm)
}

# Packages built with XBUILD (xpkg) -> xpm .xp
build_xbuild() {
    local dir="$1"
    echo "  - building $dir"
    # xpkg build -f packages/$dir/XBUILD -o "$OUT_DIR"
}

# --- pacman-facing packages (committed to public/repo) ---
if [[ "$BUILD" == "1" ]]; then
    echo "== Building packages locally =="
    build_pkgbuild x-release
    build_pkgbuild x-dev
else
    echo "== Skipping local builds (--index-only) =="
fi

echo "== Importing externally built packages =="
# x-scripts is built in the sibling scripts repo; import the newest tarball.
for pkg in ../scripts/packaging/x-scripts-*.pkg.tar.zst; do
    [ -f "$pkg" ] || continue
    echo "  + $(basename "$pkg") (x-scripts from ../scripts/packaging)"
    cp -f "$pkg" "$REPO_DIR/"
    rm -f "$pkg"
done

echo "== Copying built packages to repo =="
# Only the freshly built outputs move into the repo. The committed leftovers
# under packages/xpm, packages/xpkg, packages/xfetch and packages/xtop are NOT
# touched; import those explicitly if you ever want them in [x].
if [[ "$BUILD" == "1" ]]; then
    for dir in x-release x-dev; do
        for pkg in packages/$dir/*.pkg.tar.zst; do
            [ -f "$pkg" ] || continue
            echo "  + $pkg"
            cp "$pkg" "$REPO_DIR/"
            rm -f "$pkg"
        done
    done
else
    echo "  (nothing to copy: --index-only)"
fi

echo "== Regenerating pacman database =="
# Full rebuild from the tarballs present in the directory: this also drops
# entries for packages that no longer exist (repo-add -n would keep them).
cd "$REPO_DIR"
rm -f x.db x.files x.db.tar.gz x.files.tar.gz x.db.tar.gz.old x.files.tar.gz.old
repo-add -R x.db.tar.gz *.pkg.tar.zst
rm -f x.db x.files
cp x.db.tar.gz x.db
cp x.files.tar.gz x.files
sha256sum * > SHA256SUMS
rm -f x.db.tar.gz.old x.files.tar.gz.old

echo "== Done =="
echo "Commit public/repo/x86_64/ and push, then run the deploy workflow."
