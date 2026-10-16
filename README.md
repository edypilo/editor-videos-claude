# editor-videos-claude

Herramienta para editar tus vídeos desde Claude Code de una forma fácil, sencilla y gratuita. Las herramientas de base son gratis; los servicios de IA de pago, como las voces de ElevenLabs, son opcionales y Claude te avisa de su coste antes de usarlos.

Es un editor de vídeos que funciona hablando con [Claude Code](https://claude.com/claude-code). Está pensado para llevar los vídeos de **varios negocios** desde un mismo sitio: cada negocio tiene su carpeta con su marca, sus recursos y sus proyectos, y lo único que comparten son las herramientas.

Le pides a Claude cosas como *"Haz un reel de 15 segundos sobre el curso X"*. Claude lee la marca y los aprendizajes de ese negocio, busca material de stock, monta el vídeo con [HyperFrames](https://hyperframes.heygen.com) y lo exporta a MP4.

## Qué incluye
- **Reglas de trabajo** (`CLAUDE.md`): los negocios no se mezclan, el motor no sabe nada de marcas, se pregunta el formato y el estilo, se aprende de cada corrección, las claves están fuera del proyecto y se avisa del coste antes de usar IA.
- **Plantilla de negocio** (`negocios/_plantilla/`): `marca.json` (colores, tipografías, logo, subtítulos), contexto del negocio, aprendizajes, referencias de estilo y estructura de proyectos (`brutos/`, `trabajo/`, `exportados/`).
- **Herramientas** (`herramientas/`): búsqueda y descarga de imágenes y vídeos gratuitos de Pixabay, con galería visual para elegir.
- **Instaladores** para Windows y macOS, que instalan todo lo necesario.

## Requisitos
- [Claude Code](https://claude.com/claude-code), en terminal o en la app de escritorio de Claude (pestaña Code).
- Windows 10/11 o macOS.
- Lo demás lo instala el instalador: Git, Node.js 22+, FFmpeg, las skills de HyperFrames y, si quieres, Parakeet para transcribir en local (unos 640 MB).

## Instalación

### 1. Descargar el editor
```bash
git clone https://github.com/edypilo/editor-videos-claude.git "Editor de Videos"
cd "Editor de Videos"
```
¿No tienes Git? Descarga el ZIP desde el botón verde **Code → Download ZIP** de GitHub y descomprímelo.

### 2. Ejecutar el instalador

**Windows** (PowerShell, dentro de la carpeta):
```powershell
powershell -ExecutionPolicy Bypass -File instalar.ps1
```

**macOS** (Terminal, dentro de la carpeta; necesita [Homebrew](https://brew.sh)):
```bash
bash instalar.sh
```

Opciones de los dos instaladores: comprobar sin instalar nada (`-SoloComprobar` / `--solo-comprobar`), omitir Parakeet (`-SinParakeet` / `--sin-parakeet`) y responder que sí a todo (`-Si` / `--si`).

### 3. Poner tus claves
El instalador crea la carpeta de claves **fuera del proyecto**:
- Windows: `%USERPROFILE%\.claves\editor-videos\pixabay.env`
- macOS: `~/.claves/editor-videos/pixabay.env`

Abre `pixabay.env` y pega tu clave después de `PIXABAY_API_KEY=`. Es gratuita y se consigue en [pixabay.com/api/docs](https://pixabay.com/api/docs/) con tu cuenta iniciada.

### 4. Empezar
Abre la carpeta en Claude Code y dile, por ejemplo:

> Vamos a crear el primer negocio, que se llama Panadería Sol.

Claude copiará la plantilla y te pedirá lo que necesita: a qué se dedica el negocio, su público, su tono, los logos, los colores y las tipografías.

## Cómo se usa
| Quieres… | Dile a Claude… |
| --- | --- |
| Dar de alta un negocio | "Crea el negocio X". Después, pásale su guía de marca, sus logos y sus tipografías. |
| Que aprenda vuestro estilo | Copia vídeos ya publicados en `negocios/<negocio>/referencias/` y pídele que los analice. |
| Buscar stock | "Busca en Pixabay vídeos de café, en vertical". Te abre una galería y tú eliges por número. |
| Hacer un vídeo | "Un reel de 15 segundos sobre…". Te preguntará el formato, el estilo y el audio si no se los dices. |
| Corregir | Dile qué está mal: lo arregla y lo apunta en `aprendizajes.md` para no repetirlo. |

## Privacidad
- El `.gitignore` funciona como **lista blanca**: solo se publica la base del editor. Tus negocios (`negocios/<tu-negocio>/`), los vídeos y las claves nunca entran en el repositorio, aunque hagas `git add .`.
- Las claves están fuera de la carpeta del proyecto, y Claude tiene la regla de no leerlas ni mostrarlas nunca.

## Licencia
[MIT](LICENSE) © 2026 EddyPiLo

## Componentes de terceros
- [HyperFrames](https://github.com/heygen-com/hyperframes), de HeyGen: motor de vídeo. El instalador instala sus skills desde su repositorio oficial; no se incluyen aquí.
- [FFmpeg](https://ffmpeg.org), [Node.js](https://nodejs.org) y [Git](https://git-scm.com).
- [Pixabay API](https://pixabay.com/api/docs/): material gratuito con la [licencia de Pixabay](https://pixabay.com/service/license-summary/).
- Parakeet (NVIDIA), modelo de transcripción, instalado a través de HyperFrames.
