# Portal web

El portal es una **página estática de Next.js** con dos bloques: los enlaces a todos
los repositorios de la organización `xlnux` (animados con `XDecryptedText`) y una
explicación breve, en inglés, de que este repositorio sirve artefactos para X Linux.
No hay navbar, temas ni formularios: el sitio es una sola ruta (`/`) que se exporta
estáticamente y se despliega en GitHub Pages junto a los paquetes.

## Stack

- **Next.js 16** con App Router (`next ^16.2.9`), React 19, TypeScript (strict).
- **Tailwind CSS 4** (`@tailwindcss/postcss`) con la paleta X (`app/globals.css`).
- **@xscriptor/xcomponents** — `XDecryptedText`, la animación de descifrado de los
  enlaces, con `animateOn="view"` para que se ejecute al cargar.

La librería `@xscriptor/xcomponents` no incluye sus utilidades Tailwind, así que
`app/globals.css` tiene una directiva `@source` que hace escanear
`node_modules/@xscriptor/xcomponents/dist`.

`package.json` conserva dependencias que la página ya no usa (`three`,
`react-markdown`, `react-hook-form`); se pueden retirar en una limpieza aparte.

## Estructura del código

| Ruta | Rol |
|---|---|
| `app/layout.tsx` | Layout raíz: metadatos y fuente Anonymous Pro. |
| `app/page.tsx` | Única ruta: enlaces animados a los repos de `xlnux` y explicación. |
| `app/globals.css` | Entrada de Tailwind, paleta X, `@source` y fuente. |

## Export estático y despliegue

`next.config.mjs` mantiene `output: 'export'` y `basePath: '/x-repo'`. El workflow
`.github/workflows/build.yml` ("Deploy Website to GitHub Pages") se dispara a mano
(`workflow_dispatch`):

1. Ejecuta `npm ci && npm run build` (export estático a `./out`).
2. Comprueba que existan `x.db` y un tarball de `x-release` bajo `public/`.
3. Sube `./out` con `upload-pages-artifact` y lo despliega con `deploy-pages`.

El workflow **no construye paquetes**. Los paquetes se construyen localmente y se
commitean (ver [publishing.md](publishing.md)); el export copia `public/` completo a
`out/`, así que el repositorio `[x]` y el endpoint `.xp` se publican en el mismo
sitio:

- `out/repo/x86_64/...` → `https://xlnux.github.io/x-repo/repo/x86_64/...`
- `out/x/x86_64/...` → `https://xlnux.github.io/x-repo/x/x86_64/...`
- `public/.nojekyll` evita el procesado de Jekyll.

Publicar un paquete sigue siendo: reconstruir el repo localmente, commitear los
archivos nuevos bajo `public/` y ejecutar una vez el workflow de deploy.
