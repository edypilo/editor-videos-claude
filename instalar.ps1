# Instalador del Editor de Videos para Windows.
# Uso (desde la carpeta del editor):
#   powershell -ExecutionPolicy Bypass -File instalar.ps1
#   powershell -ExecutionPolicy Bypass -File instalar.ps1 -SoloComprobar   # no instala nada, solo revisa
#   powershell -ExecutionPolicy Bypass -File instalar.ps1 -SinParakeet     # omite el modelo de transcripcion (639 MB)
#   powershell -ExecutionPolicy Bypass -File instalar.ps1 -Si              # responde que si a todo

param(
  [switch]$SoloComprobar,
  [switch]$SinParakeet,
  [switch]$Si
)

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot
$faltan = @()

function Titulo($t) { Write-Host ""; Write-Host "== $t ==" -ForegroundColor Cyan }
function Ok($t) { Write-Host "  [OK] $t" -ForegroundColor Green }
function Aviso($t) { Write-Host "  [!]  $t" -ForegroundColor Yellow }
function RefrescarPath {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}
function Existe($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Preguntar($texto) {
  if ($Si) { return $true }
  $r = Read-Host "$texto [s/N]"
  return $r -match '^(s|si|y|yes)$'
}

function Instalar($cmd, $idWinget, $nombre) {
  if (Existe $cmd) { Ok "$nombre ya instalado"; return }
  if ($SoloComprobar) { Aviso "$nombre no esta instalado"; $script:faltan += $nombre; return }
  if (-not (Existe "winget")) { Aviso "Falta winget. Instala $nombre a mano y vuelve a ejecutar el instalador."; $script:faltan += $nombre; return }
  Write-Host "  Instalando $nombre con winget..."
  winget install --id $idWinget -e --source winget --accept-package-agreements --accept-source-agreements --silent
  RefrescarPath
  if (Existe $cmd) { Ok "$nombre instalado" } else { Aviso "No se pudo comprobar $nombre. Cierra y abre la terminal y vuelve a ejecutar el instalador."; $script:faltan += $nombre }
}

RefrescarPath

Titulo "Programas necesarios"
Instalar "git" "Git.Git" "Git"
Instalar "node" "OpenJS.NodeJS.LTS" "Node.js"
Instalar "ffmpeg" "Gyan.FFmpeg" "FFmpeg"

if (Existe "node") {
  $v = [int]((node -v).TrimStart("v").Split(".")[0])
  if ($v -lt 22) { Aviso "Node.js $v es antiguo: HyperFrames necesita la version 22 o superior. Actualiza con: winget upgrade OpenJS.NodeJS.LTS"; $faltan += "Node.js 22+" }
  else { Ok "Node.js $(node -v)" }
}

if (Existe "claude") { Ok "Claude Code (CLI) disponible" }
else { Aviso "No encuentro el comando 'claude'. No pasa nada si usas la app de escritorio de Claude: abre esta carpeta desde la pestana Code." }

Titulo "Skills de HyperFrames (motor de video)"
if (Test-Path ".claude\skills\hyperframes\SKILL.md") { Ok "Skills de HyperFrames ya instaladas" }
elseif ($SoloComprobar) { Aviso "Faltan las skills de HyperFrames"; $faltan += "Skills de HyperFrames" }
elseif (Existe "npx") {
  npx -y skills add heygen-com/hyperframes -a claude-code -y
  if (Test-Path ".claude\skills\hyperframes\SKILL.md") { Ok "Skills de HyperFrames instaladas" } else { Aviso "No se instalaron las skills de HyperFrames"; $faltan += "Skills de HyperFrames" }
}

Titulo "Transcripcion local (Parakeet, opcional)"
$parakeet = $false
if (Existe "npx") { $parakeet = [bool]((npx -y hyperframes models list 2>$null) -match "parakeet.*installed") }
if ($parakeet) { Ok "Parakeet ya instalado" }
elseif ($SoloComprobar -or $SinParakeet) { Aviso "Parakeet no instalado (opcional)" }
elseif (Preguntar "Instalar Parakeet para transcribir en local? Descarga unos 640 MB") {
  npx -y hyperframes models install parakeet
}

Titulo "Carpeta de claves (fuera del proyecto)"
$claves = Join-Path $env:USERPROFILE ".claves\editor-videos"
$pixabay = Join-Path $claves "pixabay.env"
if (Test-Path $pixabay) { Ok "Ya existe $pixabay (no se toca)" }
elseif ($SoloComprobar) { Aviso "Falta $pixabay" }
else {
  New-Item -ItemType Directory -Force $claves | Out-Null
  Set-Content -Path $pixabay -Encoding ascii -Value @(
    "# Pega tu clave de Pixabay despues del signo = (sin espacios ni comillas) y guarda.",
    "# Se obtiene en https://pixabay.com/api/docs/ con tu cuenta iniciada.",
    "PIXABAY_API_KEY="
  )
  Ok "Creado $pixabay. Abrelo y pega tu clave de Pixabay."
}

Titulo "Comprobacion de HyperFrames"
if (Existe "npx") { npx -y hyperframes doctor }

Titulo "Resultado"
if ($faltan.Count -eq 0) {
  Ok "Todo listo. Abre esta carpeta en Claude Code y pide, por ejemplo: 'Vamos a crear el primer negocio, que se llama ...'"
} else {
  Aviso ("Falta: " + ($faltan -join ", "))
  exit 1
}
