# Editor de Vídeos multinegocio

Editor de vídeos para varios negocios. Cada negocio tiene su propia carpeta con su marca, sus recursos y sus proyectos. Lo único compartido son las herramientas.

## Estructura

- `herramientas/`: lo único compartido. Nunca guarda nada específico de un negocio.
  - `scripts/`: herramientas de edición (cortar, unir, subtitular, exportar…).
  - `plantillas/`: plantillas genéricas que leen el estilo de cada negocio.
  - `presets/`: formatos de exportación (9:16, 16:9, 1:1…).
  - `config/`: ajustes globales.
- `negocios/<negocio>/`: todo lo propio de cada negocio.
  - `CLAUDE.md`: contexto del negocio (tono, público, restricciones).
  - `marca.json`: colores, tipografías, logo y estilo de subtítulos.
  - `aprendizajes.md`: correcciones y preferencias acumuladas del negocio.
  - `marca/`: logos, tipografías y colores.
  - `referencias/`: vídeos ya publicados que marcan el estilo a mantener, y `estilo-de-referencia.md` con lo que se saca de ellos.
  - `informacion/`: documentos del negocio (cursos, servicios, productos, precios internos…) para sacar contenido de los vídeos.
  - `recursos/`: intros, outros, música, sonidos y b-roll reutilizables.
  - `proyectos/AAAA-MM-DD_nombre/`: `brutos/` (no se toca), `trabajo/`, `exportados/` y `proyecto.json`.
- `negocios/_plantilla/`: modelo para dar de alta un negocio nuevo (se copia y se renombra).
- `temp/`: archivos temporales, se pueden borrar.

## Reglas

1. **Los negocios no se mezclan.** Cada negocio usa solo sus logos, estilos, recursos y proyectos. Nunca se copia ni se usa material de un negocio en otro.
2. **El motor no sabe nada de marcas.** `herramientas/` no contiene nombres, colores, logos ni estilos de ningún negocio. Las herramientas reciben el negocio como parámetro y leen su `marca.json`.
3. **Si no dije el formato o el estilo, pregúntame.** No se supone ni se elige por defecto el formato (9:16, 16:9, 1:1…) ni el estilo de un vídeo: se pregunta antes de empezar.
4. **Antes de editar, lee los aprendizajes de ese negocio; después de cada corrección, actualízalos.** Se leen en `negocios/<negocio>/aprendizajes.md` antes de cualquier edición. Cuando corrijo algo, se apunta enseguida qué estaba mal y cómo se hace bien.
5. **Las claves se guardan fuera del proyecto: nunca las leas ni las muestres.** Ninguna API key, token ni contraseña se guarda dentro de esta carpeta. No se leen, no se imprimen y no se copian en archivos, mensajes ni registros.
6. **Antes de generar algo con IA, avísame cuánto cuesta.** Antes de cualquier generación con IA (imagen, vídeo, voz, música, transcripción…) se indica el coste estimado y se espera mi confirmación.

## Herramientas disponibles

- **Pixabay** (imágenes y vídeos de stock gratuitos): `node herramientas/scripts/pixabay.mjs buscar <imagen|video> "<consulta>" [--n 10] [--orientacion vertical|horizontal] [--galeria temp/pixabay/galeria.html]` y `descargar <imagen|video> <id> <carpeta>`. La clave está fuera del proyecto (ver `herramientas/config/claves.md`).
  - Flujo: cuando pida buscar en Pixabay, generar la galería con `--galeria` (12 resultados por defecto) y abrirla en el panel del navegador. Yo elijo por número; se descargan esos ids.
  - Destino: `negocios/<negocio>/recursos/broll/` si es material reutilizable, o `proyectos/<proyecto>/trabajo/` si es solo para un proyecto. Si no dije el negocio o el destino, preguntar.
  - Junto a cada archivo se guarda un `.json` con autor y página de origen.

- **HyperFrames** (montaje y render de vídeo desde HTML): skills en `.claude/skills/`, instaladas por el instalador. Cada vídeo es un proyecto HyperFrames dentro de `proyectos/<proyecto>/trabajo/`. El render final va a `exportados/`.
  - El `package.json` del proyecto HyperFrames no puede llamarse `hyperframes`, porque entonces `npx hyperframes` deja de funcionar dentro de él. Tras `hyperframes init`, renombrarlo (por ejemplo, con el nombre del proyecto).
  - Las fuentes y los logos del negocio se copian a `assets/` del proyecto HyperFrames y se cargan con `@font-face` desde ahí.
- **Transcripción local:** `npx hyperframes transcribe <archivo> --engine parakeet --language es`. Funciona en el equipo y es gratis, pero es IA: por la regla 6, se avisa antes.

## Convenciones

- Nunca modificar ni borrar archivos de `brutos/`.
- Nombres de carpetas en minúsculas, con guiones y sin espacios ni tildes.
- **FFmpeg con texto:** pasar siempre `fontfile=` con la ruta de la fuente (normalmente la del negocio, en `marca/tipografias/`). En algunos equipos FFmpeg no trae configuración de fuentes y `drawtext` se cierra sin ella.
- **Claves:** viven en `~/.claves/editor-videos/` (en Windows, `%USERPROFILE%\.claves\editor-videos\`), un archivo `.env` por servicio. Ver `herramientas/config/claves.md`.
- **Compatibilidad:** las herramientas se escriben en Node (`.mjs`) para que funcionen igual en Windows y en macOS. Nada de rutas fijas de un equipo concreto.
