#!/usr/bin/env bash
# Instalador del Editor de Vídeos para macOS.
# Uso (desde la carpeta del editor):
#   bash instalar.sh
#   bash instalar.sh --solo-comprobar   # no instala nada, solo revisa
#   bash instalar.sh --sin-parakeet     # omite el modelo de transcripción (639 MB)
#   bash instalar.sh --si               # responde que sí a todo

cd "$(dirname "$0")" || exit 1

SOLO_COMPROBAR=0; SIN_PARAKEET=0; SI=0
for a in "$@"; do
  case "$a" in
    --solo-comprobar) SOLO_COMPROBAR=1 ;;
    --sin-parakeet) SIN_PARAKEET=1 ;;
    --si) SI=1 ;;
    *) echo "Opción desconocida: $a"; exit 2 ;;
  esac
done

FALTAN=()
titulo() { printf '\n\033[36m== %s ==\033[0m\n' "$1"; }
ok()     { printf '  \033[32m[OK]\033[0m %s\n' "$1"; }
aviso()  { printf '  \033[33m[!]\033[0m  %s\n' "$1"; }
existe() { command -v "$1" >/dev/null 2>&1; }
preguntar() {
  [ "$SI" -eq 1 ] && return 0
  read -r -p "$1 [s/N] " r
  [[ "$r" =~ ^([sS]|[sS][iíIÍ]|[yY]|[yY][eE][sS])$ ]]
}

if [ "$(uname)" != "Darwin" ]; then
  aviso "Este instalador es para macOS. En Windows usa instalar.ps1."
fi

titulo "Homebrew"
if ! existe brew; then
  for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$p" ] && eval "$("$p" shellenv)"
  done
fi
if existe brew; then
  ok "Homebrew disponible"
else
  aviso "Falta Homebrew, el gestor de paquetes de macOS. Instálalo siguiendo https://brew.sh y vuelve a ejecutar este instalador."
  FALTAN+=("Homebrew")
fi

instalar() { # comando paquete nombre
  if existe "$1"; then ok "$3 ya instalado"; return; fi
  if [ "$SOLO_COMPROBAR" -eq 1 ] || ! existe brew; then aviso "$3 no está instalado"; FALTAN+=("$3"); return; fi
  echo "  Instalando $3 con Homebrew..."
  brew install "$2"
  if existe "$1"; then ok "$3 instalado"; else aviso "No se pudo instalar $3"; FALTAN+=("$3"); fi
}

titulo "Programas necesarios"
instalar git git "Git"
instalar node node "Node.js"
instalar ffmpeg ffmpeg "FFmpeg"

if existe node; then
  v="$(node -v | sed 's/^v//' | cut -d. -f1)"
  if [ "$v" -lt 22 ]; then aviso "Node.js $v es antiguo: HyperFrames necesita la 22 o superior (brew upgrade node)."; FALTAN+=("Node.js 22+")
  else ok "Node.js $(node -v)"; fi
fi

if existe claude; then ok "Claude Code (CLI) disponible"
else aviso "No encuentro el comando 'claude'. No pasa nada si usas la app de escritorio de Claude: abre esta carpeta desde la pestaña Code."; fi

titulo "Skills de HyperFrames (motor de vídeo)"
if [ -f .claude/skills/hyperframes/SKILL.md ]; then ok "Skills de HyperFrames ya instaladas"
elif [ "$SOLO_COMPROBAR" -eq 1 ]; then aviso "Faltan las skills de HyperFrames"; FALTAN+=("Skills de HyperFrames")
elif existe npx; then
  npx -y skills add heygen-com/hyperframes -a claude-code -y
  if [ -f .claude/skills/hyperframes/SKILL.md ]; then ok "Skills de HyperFrames instaladas"; else aviso "No se instalaron las skills de HyperFrames"; FALTAN+=("Skills de HyperFrames"); fi
fi

titulo "Transcripción local (Parakeet, opcional)"
PARAKEET=0
if existe npx && npx -y hyperframes models list 2>/dev/null | grep -q "parakeet.*installed"; then PARAKEET=1; fi
if [ "$PARAKEET" -eq 1 ]; then ok "Parakeet ya instalado"
elif [ "$SOLO_COMPROBAR" -eq 1 ] || [ "$SIN_PARAKEET" -eq 1 ]; then aviso "Parakeet no instalado (opcional)"
elif preguntar "¿Instalar Parakeet para transcribir en local? Descarga unos 640 MB"; then
  npx -y hyperframes models install parakeet
fi

titulo "Carpeta de claves (fuera del proyecto)"
CLAVES="$HOME/.claves/editor-videos"
PIXABAY="$CLAVES/pixabay.env"
if [ -f "$PIXABAY" ]; then ok "Ya existe $PIXABAY (no se toca)"
elif [ "$SOLO_COMPROBAR" -eq 1 ]; then aviso "Falta $PIXABAY"
else
  mkdir -p "$CLAVES" && chmod 700 "$HOME/.claves" "$CLAVES"
  cat > "$PIXABAY" <<'EOF'
# Pega tu clave de Pixabay después del signo = (sin espacios ni comillas) y guarda.
# Se obtiene en https://pixabay.com/api/docs/ con tu cuenta iniciada.
PIXABAY_API_KEY=
EOF
  chmod 600 "$PIXABAY"
  ok "Creado $PIXABAY. Ábrelo (open -e \"$PIXABAY\") y pega tu clave de Pixabay."
fi

titulo "Comprobación de HyperFrames"
existe npx && npx -y hyperframes doctor

titulo "Resultado"
if [ "${#FALTAN[@]}" -eq 0 ]; then
  ok "Todo listo. Abre esta carpeta en Claude Code y pide, por ejemplo: 'Vamos a crear el primer negocio, que se llama ...'"
else
  aviso "Falta: ${FALTAN[*]}"
  exit 1
fi
