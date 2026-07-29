#!/usr/bin/env bash
# Install Cursor Constitution into a project.
# Usage:
#   ./scripts/install.sh                          # interactive (asks target + language)
#   ./scripts/install.sh /path/to/project         # interactive language, Source=this repo
#   ./scripts/install.sh /path/to/project ru      # non-interactive
#   ./scripts/install.sh /path/to/Constitution /path/to/project ru
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SRC="$(cd "$SCRIPT_DIR/.." && pwd)"

SRC="$DEFAULT_SRC"
TARGET=""
LOCALE=""

if [[ $# -eq 1 ]]; then
  if [[ "$1" == "en" || "$1" == "ru" ]]; then
    LOCALE="$1"
    TARGET="$(pwd)"
  else
    TARGET="$1"
  fi
elif [[ $# -eq 2 ]]; then
  if [[ "$2" == "en" || "$2" == "ru" ]]; then
    TARGET="$1"
    LOCALE="$2"
  else
    SRC="$1"
    TARGET="$2"
  fi
elif [[ $# -ge 3 ]]; then
  SRC="$1"
  TARGET="$2"
  LOCALE="$3"
fi

select_locale() {
  local options=("ru" "en")
  local labels=("ru  - Russian (docs + project-memory)" "en  - English (docs + project-memory)")
  local idx=0
  local typed=""
  local key

  if [[ ! -t 0 ]]; then
    while true; do
      read -r -p "Locale [ru/en]: " typed
      typed="$(echo "$typed" | tr '[:upper:]' '[:lower:]')"
      case "$typed" in
        ru|en) echo "$typed"; return ;;
        1) echo ru; return ;;
        2) echo en; return ;;
      esac
      echo "Please enter ru or en" >&2
    done
  fi

  echo ""
  echo "Select language"
  echo "  Up/Down + Enter  - move and confirm"
  echo "  Or type ru / en and press Enter"
  echo ""

  draw() {
    local n prefix
    for n in 0 1; do
      if [[ $n -eq $idx ]]; then prefix="> "; else prefix="  "; fi
      printf "%s%s\n" "$prefix" "${labels[$n]}"
    done
    if [[ -n "$typed" ]]; then
      printf "  typed: %s_\n" "$typed"
    else
      printf "  typed: (optional)_\n"
    fi
  }

  draw
  while true; do
    IFS= read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 -t 0.1 rest || true
      case "$rest" in
        '[A') idx=$(( (idx - 1 + 2) % 2 )); typed="" ;; # up
        '[B') idx=$(( (idx + 1) % 2 )); typed="" ;; # down
      esac
    elif [[ $key == "" ]]; then
      # Enter
      if [[ "$typed" == "ru" || "$typed" == "en" ]]; then
        echo "$typed"; return
      elif [[ "$typed" == "1" ]]; then
        echo ru; return
      elif [[ "$typed" == "2" ]]; then
        echo en; return
      elif [[ -z "$typed" ]]; then
        echo "${options[$idx]}"; return
      else
        echo "Unknown: $typed - use ru or en" >&2
        typed=""
      fi
    elif [[ $key == $'\x7f' || $key == $'\b' ]]; then
      typed="${typed%?}"
    elif [[ $key =~ [a-zA-Z0-9] ]]; then
      typed+="$(echo "$key" | tr '[:upper:]' '[:lower:]')"
      if [[ "$typed" == "ru" ]]; then idx=0; fi
      if [[ "$typed" == "en" ]]; then idx=1; fi
    fi
    # redraw
    printf '\033[%sA' 3
    draw
  done
}

SRC="$(cd "$SRC" && pwd)"
if [[ ! -d "$SRC/template/.cursor/rules" ]]; then
  echo "Not a Cursor-Constitution repo: $SRC" >&2
  exit 1
fi

if [[ -z "$TARGET" ]]; then
  cwd="$(pwd)"
  if [[ "$cwd" == "$SCRIPT_DIR" || "$cwd" == "$SRC" || "$cwd" == "$SRC/scripts" || "$cwd" == "$SRC/template" ]]; then
    echo "Constitution source: $SRC"
    read -r -p "Target project path: " TARGET
    TARGET="${TARGET%\"}"; TARGET="${TARGET#\"}"
    if [[ -z "$TARGET" ]]; then
      echo "Target project path is required." >&2
      exit 1
    fi
  else
    TARGET="$cwd"
    echo "Install target (current folder): $TARGET"
    read -r -p "OK? [Y/n] " confirm
    if [[ "$confirm" =~ ^[Nn] ]]; then
      read -r -p "Target project path: " TARGET
      if [[ -z "$TARGET" ]]; then
        echo "Target project path is required." >&2
        exit 1
      fi
    fi
  fi
fi

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

if [[ -z "$LOCALE" ]]; then
  LOCALE="$(select_locale)"
fi

if [[ "$LOCALE" != "en" && "$LOCALE" != "ru" ]]; then
  echo "Locale must be en or ru" >&2
  exit 1
fi

echo ""
echo "Language pack: $LOCALE"
echo "Source:        $SRC"
echo "Target:        $TARGET"
echo ""

RULES_SRC="$SRC/template/.cursor/rules"
DOCS_SRC="$SRC/docs/$LOCALE"
MEMORY_SRC="$DOCS_SRC/project-memory"

for p in "$RULES_SRC" "$DOCS_SRC" "$MEMORY_SRC"; do
  if [[ ! -e "$p" ]]; then
    echo "Missing required path: $p" >&2
    exit 1
  fi
done

cd "$TARGET"
mkdir -p .cursor/rules docs .cursor/project-memory
cp -R "$RULES_SRC/." .cursor/rules/

shopt -s dotglob nullglob
for item in "$DOCS_SRC"/*; do
  name="$(basename "$item")"
  if [[ "$name" == "project-memory" ]]; then
    continue
  fi
  cp -R "$item" docs/
done
shopt -u dotglob nullglob

cp -R "$MEMORY_SRC/." .cursor/project-memory/

if [[ "$LOCALE" == "ru" ]]; then
  COMM="Russian"
else
  COMM="English"
fi

STACK=".cursor/rules/project/stack.mdc"
tmp="$(mktemp)"
sed \
  -e "s|^\\(- \\*\\*Communication language:\\*\\*\\).*|\\1 $COMM|" \
  -e "s|^\\(- \\*\\*Docs locale:\\*\\*\\).*|\\1 $LOCALE (content unpacked into docs/)|" \
  -e "s|^\\(- \\*\\*UI / product copy:\\*\\*\\).*|\\1 same as communication (change in onboarding if needed)|" \
  -e "s|^\\(- Docs root:\\).*|\\1 docs|" \
  "$STACK" > "$tmp"
mv "$tmp" "$STACK"

echo "Installed."
echo "  Rules:           .cursor/rules/          (English)"
echo "  Docs:            docs/                   (from docs/$LOCALE pack)"
echo "  Project memory:  .cursor/project-memory/ ($COMM)"
echo "  stack.mdc:       Communication language=$COMM, Docs locale=$LOCALE, Docs root=docs"
echo ""
echo "Next: open the project in Cursor and run onboarding from .cursor/rules/onboarding.mdc"
