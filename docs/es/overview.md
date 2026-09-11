# Descripción general

`xlnux/x-repo` es el repositorio de **repositorio de paquetes + portal web** del
ecosistema X Linux. Tiene dos roles que conviven en el mismo repo:

1. **Repositorio binario de paquetes** — los paquetes precompilados de X y la base de
   datos de pacman se commitean bajo `public/` y se sirven tal cual en GitHub Pages
   como el repositorio `[x]` de pacman (y, bajo `public/x/`, como el endpoint nativo
   `.xp` que usa `xpm`).
2. **Portal web** — una página Next.js que explica el repositorio (endpoints, uso con
   pacman/xpm, paquetes y flujo de publicación) y se exporta como sitio estático al
   mismo GitHub Pages.

Los paquetes **no** se construyen en CI. Se construyen localmente, se commitean al
repo, y lo único que hace el workflow de deploy es reconstruir la web y publicar todo
el árbol `public/` en GitHub Pages. Ver [web-portal.md](web-portal.md) y
[publishing.md](publishing.md).

## Rol dentro de la organización xlnux

`x-repo` es uno de los cinco repositorios de la organización **xlnux**. Cada repo
tiene un rol único y claro:

| Repositorio | Rol |
|---|---|
| `xlnux/x` | La distro. Perfil ArchISO, build de ISO/instalador y branding del sistema. |
| `xlnux/scripts` | Payload de aprovisionamiento y setup de usuario. Incluye el CLI `x` y construye el paquete `x-scripts`. |
| `xlnux/xpkg` | Builder de paquetes en Rust. Produce paquetes nativos `.xp` desde archivos `XBUILD`. |
| `xlnux/xpm` | Gestor de paquetes en Rust, la contraparte nativa de pacman. |
| `xlnux/x-repo` | **Repositorio binario de paquetes + portal web** (este repositorio). |

Coexisten dos vías de empaquetado en el ecosistema:

- **PKGBUILD + makepkg** — paquetes compatibles con Arch (`.pkg.tar.zst`) consumibles
  por pacman. Es la vía que hoy alimenta el repositorio `[x]` de pacman.
- **XBUILD + xpkg** — paquetes nativos (`.xp`) consumibles por `xpm`. El tooling está
  listo, pero el workflow nativo automatizado está **pendiente** (ver
  `docs/build-x-native-workflow.md`).

## Qué contiene este repositorio

| Ruta | Propósito |
|---|---|
| `packages/` | Fuentes de paquetes. `PKGBUILD` (vía pacman) y, donde exista, `XBUILD` (vía nativa) por paquete. |
| `public/` | Contenido estático servido en Pages. `public/repo/x86_64/` contiene el repositorio `[x]` de pacman; `public/x/x86_64/` el endpoint nativo `.xp`; el resto son assets de la web. |
| `build-packages.sh` | Script local para construir los paquetes de la vía pacman y regenerar la base de datos del repo. |
| `app/` | Código fuente de la página Next.js. |
| `.github/workflows/` | CI/CD. `build.yml` construye y despliega el sitio en GitHub Pages. |
| `docs/` | Documentación del repositorio (este directorio y `build-x-native-workflow.md`). |

Ver [repo-layout.md](repo-layout.md) para el detalle de la estructura y
[web-portal.md](web-portal.md) para el sitio web.
