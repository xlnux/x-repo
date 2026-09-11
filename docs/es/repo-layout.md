# Estructura del repositorio

## Nivel superior

```
app/                  Página Next.js (layout, page y estilos)
packages/             Fuentes de paquetes y artefactos de build
public/               Contenido estático servido en GitHub Pages
  repo/x86_64/        Repositorio [x] de pacman (db + tarballs .pkg.tar.zst)
  x/x86_64/           Endpoint nativo (.xp) usado por xpm
  images/, fonts/     Assets de la web
build-packages.sh     Script local de build + repo-add
docs/                 Documentación
.github/workflows/    Workflows de CI/CD
```

## packages/

Un directorio por paquete. Cada uno puede contener un `PKGBUILD`, un `XBUILD`, o
ambos, además de los archivos propios del paquete.

- `PKGBUILD` — descriptor de fuente compatible con Arch. Se construye con `makepkg` y
  produce un `.pkg.tar.zst` para el repositorio de **pacman**.
- `XBUILD` — descriptor nativo para la vía **xpkg/xpm**, produce un paquete `.xp`.
  El workflow nativo que lo consumía está desactivado; se conserva como referencia en
  `docs/build-x-native-workflow.md`.

El README señala que mientras `PKGBUILD` se mantiene para el tooling legacy de Arch,
`XBUILD` es la vía nativa para `xpkg`/`xpm`.

### Paquetes construibles (PKGBUILD)

- **`x-release`** — identidad y branding de X Linux (PKGBUILD `1.0-8`). Incluye la
  plantilla `os-release`, defaults de GRUB, logo de distribución, fondos y la
  herramienta `x-release-apply`, además de hooks de pacman (`99-x-os-release.hook`,
  `99-x-grub.hook`) que reaplican el branding tras actualizaciones de
  `filesystem`/`grub`.
- **`x-dev`** — paquete de entorno de desarrollo (PKGBUILD `1.0-2`). Instala
  `/usr/bin/x-dev-env` y helpers bajo `/usr/share/x-dev/` (aliases de shell, scripts
  de setup de NVIDIA/QEMU/Node). Depende de `zsh git base-devel curl wget`.
  `install=x-dev.install` ejecuta la lógica post-instalación.

Hoy solo estos dos se construyen desde su `PKGBUILD` con `build-packages.sh`.

### x-scripts: artefacto importado, sin fuente aquí

`x-scripts` **no** se construye en este repositorio. Su `PKGBUILD` vive en el repo
hermano `xlnux/scripts` bajo `scripts/packaging/` y empaqueta todo el payload de
aprovisionamiento (fases, CLI `x`, configs). El tarball resultante se construye allí y
se **importa** a este repo, commiteado bajo `public/repo/x86_64/` (actualmente
`x-scripts-0.1.0-1-any.pkg.tar.zst`).

- No existe un directorio de fuente `packages/x-scripts/` aquí.
- El artefacto publicado en este repo es la versión `0.1.0-1`; el `PKGBUILD` del repo
  `scripts` ha avanzado desde entonces (pkgrel 11). Re-importa un build actualizado
  desde `scripts/packaging/` al republicar el payload.

### Artefactos preconstruidos, sin fuentes

- `packages/xpm/`, `packages/xpkg/` — binarios `.xp` commiteados (con archivos `.sig`).
- `packages/xfetch/`, `packages/xtop/` — binarios `.pkg.tar.zst` commiteados.

Son restos de la vía de empaquetado nativa, no fuentes. El workflow nativo que los
regeneraba desde repos upstream está desactivado (ver
`docs/build-x-native-workflow.md`).

## public/repo/x86_64/ — el repositorio [x] de pacman

Este directorio es el repositorio orientado a pacman. Archivos presentes:

| Archivo | Rol |
|---|---|
| `x.db`, `x.db.tar.gz` | Base de datos de paquetes (`x.db` es la copia sin comprimir de `x.db.tar.gz`). |
| `x.files`, `x.files.tar.gz` | Base de datos de listas de archivos para `pacman -F`. |
| `*.pkg.tar.zst` | Los paquetes: `x-release-1.0-8`, `x-dev-1.0-2`, `x-scripts-0.1.0-1`, `xpm-0.1.0-3`. |
| `SHA256SUMS` | Checksums de todos los archivos del directorio. |
| `signing.pub`, `trustedkeys.gpg` | Material de firma/confianza consumido por el endpoint nativo. |

Los clientes configuran el repositorio en `pacman.conf` como:

```
[x]
Server = https://xlnux.github.io/x-repo/repo/x86_64
```

### Cómo se actualiza la base de datos (repo-add)

La base de datos nunca se edita a mano. `build-packages.sh` la regenera con
`repo-add`:

```bash
cd public/repo/x86_64
rm -f x.db x.files x.db.tar.gz.old x.files.tar.gz.old
repo-add -n -R x.db.tar.gz *.pkg.tar.zst
rm -f x.db x.files
cp x.db.tar.gz x.db
cp x.files.tar.gz x.files
sha256sum * > SHA256SUMS
```

- `repo-add` crea `x.db.tar.gz` y `x.files.tar.gz` a partir de los `.pkg.tar.zst`.
- `-R` elimina de la base cualquier paquete que ya no esté en el directorio (limpieza
  de versiones antiguas); `-n` solo añade paquetes que no estén ya en la base.
- `x.db`/`x.files` son copias planas de los `.tar.gz` para que pacman pueda leerlos
  directamente.
- Hoy no se pasa bandera de firma, así que la base se regenera sin firmar.
- `SHA256SUMS` se regenera a partir de todos los archivos del directorio.

## public/x/x86_64/ — endpoint nativo .xp

Endpoint complementario para `xpm`. Contiene paquetes `.xp` (`xpkg`, `xpm`,
`x-release`), su propia base de datos (`x.db.tar.gz`, `x.files.tar.gz`),
`signing.pub`/`trustedkeys.gpg` y un `SHA256SUMS`. Fue generado por el workflow nativo
desactivado y se sirve en `https://xlnux.github.io/x-repo/x/x86_64/`. La URL de
repositorio documentada para `xpm` es `https://xlnux.github.io/x-repo/x/$arch`.

## build-packages.sh

Script local (se ejecuta desde la raíz del repo; requiere un entorno tipo Arch con
`makepkg` y `repo-add`). El script:

1. Construye en su sitio los paquetes PKGBUILD configurados
   (`build_pkgbuild x-release`, `build_pkgbuild x-dev`) con `makepkg -cf --noconfirm`.
   El helper `build_xbuild` para la vía nativa existe pero está comentado.
2. Copia todos los `packages/*/*.pkg.tar.zst` a `public/repo/x86_64/` y elimina el
   artefacto de build después.
3. Regenera la base de datos de pacman y `SHA256SUMS` como se muestra arriba.
4. Imprime el recordatorio final:

```
Commit public/repo/x86_64/ and push, then run the deploy workflow.
```

Para añadir un paquete PKGBUILD nuevo al flujo, añade su directorio a las llamadas
`build_pkgbuild`. Para importar un paquete construido externamente (como `x-scripts`),
coloca su `.pkg.tar.zst` de forma que el paso de copia lo recoja (p. ej. dentro de un
directorio `packages/*/`) o directamente en `public/repo/x86_64/` antes de ejecutar el
script.
