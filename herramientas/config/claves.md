# Claves de servicios externos

Las claves nunca se guardan dentro del proyecto (regla 5). Aquí solo se apunta dónde están y qué variable contienen.

Carpeta:
- macOS: `~/.claves/editor-videos/`
- Windows: `%USERPROFILE%\.claves\editor-videos\`

El instalador la crea con los archivos vacíos. Cada usuario pega sus propias claves.

| Servicio | Archivo | Variable | Dónde se consigue |
| --- | --- | --- | --- |
| Pixabay | `pixabay.env` | `PIXABAY_API_KEY` | https://pixabay.com/api/docs/ (con la sesión iniciada) |

Las herramientas cargan el archivo `.env` cuando se ejecutan. Su contenido nunca se lee, se imprime ni se copia.
