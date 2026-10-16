// Búsqueda de imágenes y vídeos en Pixabay.
// La clave se carga de %USERPROFILE%\.claves\editor-videos\pixabay.env y nunca se imprime.
//
// Uso:
//   node herramientas/scripts/pixabay.mjs buscar <imagen|video> "<consulta>" [--n 10] [--orientacion vertical|horizontal] [--idioma es] [--galeria <archivo.html>]
//   node herramientas/scripts/pixabay.mjs descargar <imagen|video> <id> <carpeta-destino>

import { readFileSync, mkdirSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

const ARCHIVO_CLAVE = join(homedir(), ".claves", "editor-videos", "pixabay.env");

function cargarClave() {
  let texto;
  try {
    texto = readFileSync(ARCHIVO_CLAVE, "utf8");
  } catch {
    salir(`No se encuentra el archivo de la clave: ${ARCHIVO_CLAVE}`);
  }
  const linea = texto.split(/\r?\n/).find((l) => l.trim().startsWith("PIXABAY_API_KEY="));
  const clave = linea ? linea.split("=").slice(1).join("=").trim() : "";
  if (!clave) salir("PIXABAY_API_KEY está vacía en el archivo de la clave.");
  return clave;
}

function salir(mensaje) {
  console.error(mensaje);
  process.exit(1);
}

function opciones(args) {
  const o = { n: 10, orientacion: "all", idioma: "es" };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--n") o.n = Number(args[++i]);
    else if (args[i] === "--orientacion") o.orientacion = args[++i];
    else if (args[i] === "--idioma") o.idioma = args[++i];
    else if (args[i] === "--galeria") o.galeria = args[++i];
  }
  return o;
}

const ORIENTACION = { vertical: "vertical", horizontal: "horizontal", all: "all" };

async function pedir(tipo, parametros) {
  const base = tipo === "video" ? "https://pixabay.com/api/videos/" : "https://pixabay.com/api/";
  const url = new URL(base);
  url.searchParams.set("key", cargarClave());
  for (const [k, v] of Object.entries(parametros)) url.searchParams.set(k, String(v));
  const res = await fetch(url);
  const cuerpo = await res.text();
  // Los mensajes de error de Pixabay no incluyen la clave; la URL nunca se muestra.
  if (!res.ok) salir(`Pixabay respondió ${res.status}: ${cuerpo.slice(0, 200)}`);
  return JSON.parse(cuerpo);
}

function resumir(tipo, h) {
  if (tipo === "video") {
    const v = h.videos.large?.url ? h.videos.large : h.videos.medium;
    return { id: h.id, etiquetas: h.tags, duracion: h.duration, ancho: v.width, alto: v.height, autor: h.user, pagina: h.pageURL };
  }
  return { id: h.id, etiquetas: h.tags, ancho: h.imageWidth, alto: h.imageHeight, autor: h.user, pagina: h.pageURL };
}

async function buscar(tipo, consulta, args) {
  const o = opciones(args);
  const datos = await pedir(tipo, {
    q: consulta,
    lang: o.idioma,
    per_page: Math.min(Math.max(o.n, 3), 200),
    safesearch: "true",
    ...(tipo === "imagen" ? { orientation: ORIENTACION[o.orientacion] ?? "all" } : {}),
  });
  const hits = datos.hits.slice(0, o.n);
  const resultados = hits.map((h, i) => ({ n: i + 1, ...resumir(tipo, h) }));
  if (o.galeria) {
    escribirGaleria(o.galeria, tipo, consulta, datos.totalHits, hits, resultados);
    console.log(o.galeria);
  } else {
    console.log(JSON.stringify({ total: datos.totalHits, resultados }, null, 2));
  }
}

const escapar = (s) => String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);

function escribirGaleria(archivo, tipo, consulta, total, hits, resultados) {
  const tarjetas = hits
    .map((h, i) => {
      const r = resultados[i];
      const medio =
        tipo === "video"
          ? `<video src="${escapar(h.videos.tiny.url)}" poster="${escapar(h.videos.tiny.thumbnail)}" controls muted loop preload="none"></video>`
          : `<img src="${escapar(h.webformatURL)}" alt="${escapar(h.tags)}" loading="lazy">`;
      const datos = tipo === "video" ? `${r.ancho}x${r.alto} · ${r.duracion} s` : `${r.ancho}x${r.alto}`;
      return `<figure><span class="n">${r.n}</span>${medio}<figcaption><b>#${r.n}</b> · id ${r.id} · ${datos}<br><span>${escapar(r.etiquetas)}</span><br><a href="${escapar(r.pagina)}" target="_blank">${escapar(r.autor)} en Pixabay</a></figcaption></figure>`;
    })
    .join("\n");
  const html = `<!doctype html>
<html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Pixabay: ${escapar(consulta)}</title>
<style>
:root{--fondo:#f6f6f7;--tarjeta:#fff;--texto:#18181b;--suave:#71717a;--acento:#0284c7}
@media (prefers-color-scheme:dark){:root{--fondo:#0e1116;--tarjeta:#181b22;--texto:#f4f4f5;--suave:#a1a1aa;--acento:#38bdf8}}
body{margin:0;padding:16px;background:var(--fondo);color:var(--texto);font:14px/1.4 system-ui,sans-serif}
h1{font-size:18px;margin:0 0 4px}p{margin:0 0 16px;color:var(--suave)}
main{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:14px}
figure{position:relative;margin:0;background:var(--tarjeta);border-radius:10px;overflow:hidden}
img,video{display:block;width:100%;height:300px;object-fit:cover;background:#000}
.n{position:absolute;top:8px;left:8px;background:var(--acento);color:#fff;font-weight:700;border-radius:999px;min-width:28px;height:28px;display:grid;place-items:center;font-size:15px}
figcaption{padding:8px 10px 10px;font-size:12px}figcaption span{color:var(--suave)}a{color:var(--acento)}
</style></head><body>
<h1>${tipo === "video" ? "Vídeos" : "Imágenes"} de Pixabay: “${escapar(consulta)}”</h1>
<p>${hits.length} de ${total} resultados. Dime en el chat los números que quieres descargar y para qué negocio.</p>
<main>
${tarjetas}
</main></body></html>`;
  mkdirSync(dirname(archivo), { recursive: true });
  writeFileSync(archivo, html);
}

async function descargar(tipo, id, destino) {
  const datos = await pedir(tipo, { id });
  const h = datos.hits[0];
  if (!h) salir(`No existe ningún ${tipo} con id ${id}.`);
  const origen =
    tipo === "video" ? (h.videos.large?.url || h.videos.medium.url) : (h.largeImageURL || h.webformatURL);
  const extension = tipo === "video" ? "mp4" : origen.split(".").pop().split("?")[0];
  const res = await fetch(origen);
  if (!res.ok) salir(`No se pudo descargar (${res.status}).`);
  mkdirSync(destino, { recursive: true });
  const archivo = join(destino, `pixabay-${tipo}-${id}.${extension}`);
  writeFileSync(archivo, Buffer.from(await res.arrayBuffer()));
  writeFileSync(`${archivo}.json`, JSON.stringify({ fuente: "Pixabay", ...resumir(tipo, h) }, null, 2));
  console.log(archivo);
}

const [accion, tipo, ...resto] = process.argv.slice(2);
if (!["imagen", "video"].includes(tipo)) salir("El tipo debe ser 'imagen' o 'video'.");
if (accion === "buscar" && resto[0]) await buscar(tipo, resto[0], resto.slice(1));
else if (accion === "descargar" && resto[0] && resto[1]) await descargar(tipo, resto[0], resto[1]);
else salir("Uso: pixabay.mjs buscar <imagen|video> \"<consulta>\" [--n 10] [--orientacion vertical]  |  descargar <imagen|video> <id> <carpeta>");
