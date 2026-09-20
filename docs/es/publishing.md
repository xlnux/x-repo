# Publicar un paquete

Publicar en el repositorio `[x]` de pacman es un flujo de **build local y luego
commit**. GitHub Actions nunca construye paquetes; solo despliega lo que está
commiteado bajo `public/` (ver [web-portal.md](web-portal.md)).

El ciclo completo: build local -> `repo-add` -> `SHA256SUMS` -> PR -> deploy en Pages.

## 1. Build local

Requisitos: un entorno tipo Arch con `makepkg` y `repo-add` disponibles.

### Paquete construido desde un PKGBUILD de este repo

Trabaja sobre la fuente del paquete y luego constrúyelo dentro de su directorio
exactamente como hace `build-packages.sh`:

```bash
cd packages/x-release      # o packages/x-dev
makepkg -cf --noconfirm
```

Esto produce un `.pkg.tar.zst` (p. ej. `x-release-1.0-8-any.pkg.tar.zst`) dentro del
directorio del paquete.

### Paquete externo (x-scripts)

`x-scripts` se construye en el repo hermano `scripts` (su `PKGBUILD` vive en
`scripts/packaging/`), no aquí, y lleva el snapshot offline del escritorio equisdots
que usa el instalador. Constrúyelo allí:

```bash
cd scripts/packaging && makepkg -f
```

`build-packages.sh` importa automáticamente el
`../scripts/packaging/x-scripts-*.pkg.tar.zst` resultante y lo elimina del directorio
de build. También puedes colocar el tarball directamente en
`public/repo/x86_64/` antes de ejecutar el script. No existe un directorio de fuente
`packages/x-scripts/` en este repo.

### Paquetes nativos .xp (vía xpm/xpkg)

El endpoint `.xp` bajo `public/x/x86_64/` queda fuera del alcance de este flujo: el
workflow nativo automatizado está desactivado y se conserva como referencia en
`docs/build-x-native-workflow.md`.

## 2. Regenerar el repositorio (repo-add)

Desde la raíz del repositorio ejecuta:

```bash
./build-packages.sh              # construye x-release/x-dev + importa x-scripts + indexa
./build-packages.sh --index-only # omite los builds locales (solo importa/indexa)
```

El script:

1. Reconstruye los paquetes PKGBUILD configurados (`x-release`, `x-dev`) con
   `makepkg` salvo con `--index-only`.
2. Importa `../scripts/packaging/x-scripts-*.pkg.tar.zst` cuando existe y copia los
   tarballs recién construidos de `x-release`/`x-dev` a `public/repo/x86_64/`,
   borrando solo esos artefactos de build. Los binarios commiteados bajo
   `packages/xpm`, `packages/xpkg`, `packages/xfetch` y `packages/xtop` no se tocan.
3. Reconstruye la base de datos de pacman desde cero a partir de todos los tarballs
   del directorio (esto también elimina entradas de paquetes que ya no existen):

   ```bash
   repo-add -R x.db.tar.gz *.pkg.tar.zst
   cp x.db.tar.gz x.db
   cp x.files.tar.gz x.files
   sha256sum * > SHA256SUMS
   ```

No edites `x.db` ni `SHA256SUMS` a mano; regenéralos siempre con este script (las
reglas de contribución en `CONTRIBUTING.md` también prohíben ediciones manuales de la
base de datos).

## 3. Revisar y commitear

Comprueba qué cambió bajo `public/repo/x86_64/`:

```bash
git status
git diff --stat
```

Cambios esperados para una actualización de paquete:

- el nuevo `.pkg.tar.zst` (y la eliminación de la versión reemplazada),
- `x.db`, `x.db.tar.gz`, `x.files`, `x.files.tar.gz` regenerados,
- `SHA256SUMS` regenerado,
- el propio cambio del `PKGBUILD` bajo `packages/`.

Commitea los cambios del repositorio, por ejemplo:

```bash
git add packages/x-release public/repo/x86_64
git commit -m "publish x-release 1.0-8"
```

## 4. Pull request

Según `CONTRIBUTING.md`, el flujo de contribución es fork, rama y pull request contra
la rama `main`. Los mantenedores también pueden commitear a una rama de trabajo y abrir
el PR directamente. Fusiona a `main` cuando pase la validación.

## 5. Desplegar en GitHub Pages

Cuando los cambios estén en `main`, despliega el sitio para que los archivos nuevos del
repo salgan en producción:

1. Ve a la pestaña **Actions** de `xlnux/x-repo`.
2. Ejecuta manualmente el workflow **"Deploy Website to GitHub Pages"** (`build.yml`)
   mediante `workflow_dispatch`.
3. El workflow ejecuta `npm ci && npm run build` (export estático del sitio Next.js
   incluido todo lo de `public/`), comprueba que existan `x.db` y un tarball de
   `x-release`, y sube `./out` a GitHub Pages.

Los paquetes actualizados quedan servidos en:

- `https://xlnux.github.io/x-repo/repo/x86_64/` (repo `[x]` de pacman)

### Advertencias

- No ejecutes dos workflows de deploy de Pages a la vez; se sobrescribirían el
  despliegue mutuamente (en `build.yml` hay un grupo de concurrencia `pages`, y
  `docs/build-x-native-workflow.md` avisa de lo mismo para el workflow nativo, que está
  desactivado).
- Mantén el repositorio sincronizado con sus consumidores: `x-release` y `x-dev` se
  instalan desde este repo durante la instalación de la distro X, y `x-scripts` debe
  coincidir con la revisión del payload que espera el instalador.
