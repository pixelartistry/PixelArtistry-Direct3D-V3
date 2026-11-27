#!/usr/bin/env bash
# UltraTex for ComfyUI on Linux - installer by PixelArtistry
#
# NOT TESTED. I have no Linux machine with an NVIDIA card. This script follows the same steps as the tested
# Windows installer, but nobody has run it yet. Read it before you run it, and please report what happens.
#
# What it covers:  UltraTex Modular nodes (Mstafa-awad/UltraTex-ComfyUI-nodes, GPL-3.0), ComfyUI-GGUF
#                   (city96, Apache-2.0) and the models they need. Whether the UltraTex Modular pack runs on
#                   Linux is not known: its author developed and tested it on Windows. It also needs Triton,
#                   which this script does not install.
# What it cannot cover:
#   - Direct3D-V3: the ComfyUI node pack (Mstafa-awad/Direct3D-V3_Comfyui_Nodes) is Windows-only. It ships a
#     compiled Windows voxelizer and its setup refuses other systems. There is no Linux build to install.
#   - WTiVo: ships Windows binaries only.
# So on Linux this gives you the texturing half of the workflows, not the refiner.
#
# Usage:   ./install_ultratex_linux.sh /path/to/ComfyUI [--no-models]
#          COMFY_PY=/path/to/python ./install_ultratex_linux.sh /path/to/ComfyUI
# The Python must be the one ComfyUI runs with (its venv). Safe to run twice: existing files are kept.
set -euo pipefail

UT_COMMIT="4dea3ff0c61e0ec0aa82808ffe2299f14089db92"
UT_REPO="https://github.com/Mstafa-awad/UltraTex-ComfyUI-nodes"
GG_COMMIT="4dfc025e4be06ba9c210bd1189546f7af67f445d"
GG_REPO="https://github.com/city96/ComfyUI-GGUF"
COMFYORG="https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/1138ce884c8e977cdacacbe779784fec4426bb3f/split_files"
UTX="https://www.modelscope.ai/models/Yibo-Zhang/UltraTex/resolve/master"
LORA_SHA="3b1915177a81bc2ab43f501355bf39113df0128e6cbc6fedf8b8621d5e06a01c"
DEC_SHA="981dc4c52481687c6da4e6211617615a2b2bcc33456e1953ee6c5478aa00025b"
KLEIN_FILE="flux-2-klein-base-9b-Q4_0.gguf"
KLEIN_URL="https://huggingface.co/unsloth/FLUX.2-klein-base-9B-GGUF/resolve/62ede6c5d20015b63112603ae59b556ca75f5bc9/flux-2-klein-base-9b-Q4_0.gguf"
KLEIN_SHA="02d4c2b55b5a6d4aca65eafd0f0eabe8c1e3837391042b6879be04eb99c7e116"
QWEN_FILE="Qwen3-8B-Q6_K.gguf"
QWEN_URL="https://huggingface.co/unsloth/Qwen3-8B-GGUF/resolve/a6adef130ffb23ddaf1a62fec9dced968c9bc482/Qwen3-8B-Q6_K.gguf"
QWEN_SHA="0eaec718fdeab0f429dfa0ec481c090388811f5e63785ddb582292f4ef3c3827"

COMFY="${1:-}"
NO_MODELS=0
[ "${2:-}" = "--no-models" ] && NO_MODELS=1
if [ -z "$COMFY" ] || [ ! -f "$COMFY/main.py" ]; then
    echo "Usage: $0 /path/to/ComfyUI [--no-models]   (the folder that contains main.py)"
    exit 1
fi
COMFY="$(cd "$COMFY" && pwd)"

PY="${COMFY_PY:-}"
if [ -z "$PY" ]; then
    for c in "$COMFY/venv/bin/python" "$COMFY/.venv/bin/python" "$COMFY/../venv/bin/python" "$COMFY/../.venv/bin/python"; do
        [ -x "$c" ] && PY="$c" && break
    done
fi
if [ -z "$PY" ]; then
    echo "Could not find ComfyUI's Python. Set COMFY_PY to the python of ComfyUI's environment and run again."
    exit 1
fi
echo "ComfyUI: $COMFY"
echo "Python:  $PY"
"$PY" -c "import torch; print('PyTorch', torch.__version__, '| CUDA available:', torch.cuda.is_available())"

if pgrep -f "$COMFY/main.py" >/dev/null 2>&1; then
    echo "ComfyUI seems to be running. Close it first, then run this again."
    exit 1
fi

SNAP_BEFORE="$COMFY/ultratex_pip_before.txt"
SNAP_AFTER="$COMFY/ultratex_pip_after.txt"
[ -f "$SNAP_BEFORE" ] || "$PY" -m pip freeze > "$SNAP_BEFORE"
echo "Package list saved: $SNAP_BEFORE"

# 1. node packs
get_pack() {  # folder name, repo, commit, file that proves a complete install
    local dir="$COMFY/custom_nodes/$1"
    if [ -f "$dir/$4" ]; then echo "$1 already installed - left as it is."; return 0; fi
    if [ -e "$dir" ]; then echo "$dir exists but is not a complete install. Rename or delete it yourself, then run this again."; exit 1; fi
    command -v git >/dev/null || { echo "git is needed to download the node packs."; exit 1; }
    git clone "$2" "$dir"
    git -C "$dir" checkout --quiet "$3"
    echo "Installed $1 at commit ${3:0:7}."
}
NODE="$COMFY/custom_nodes/comfyui_ultratex_modular"
get_pack "comfyui_ultratex_modular" "$UT_REPO" "$UT_COMMIT" "extension.py"
get_pack "ComfyUI-GGUF" "$GG_REPO" "$GG_COMMIT" "nodes.py"
"$PY" -c "import importlib.util as u, sys; sys.exit(0 if u.find_spec('triton') else 1)"     || echo "WARNING: Triton is not installed in this Python. UltraTex needs it; this script does not install it."

# 2. Python packages: only what is missing, never change an installed version
MISSING="$("$PY" -c "import importlib.util as u; print(' '.join(p for p in ('trimesh','moderngl','glcontext','scipy','einops','psutil','threadpoolctl','gguf') if u.find_spec(p) is None))")"
if [ -z "$MISSING" ]; then
    echo "Python packages: nothing missing."
else
    echo "Missing packages: $MISSING"
    # shellcheck disable=SC2086
    "$PY" -m pip install --dry-run $MISSING > /tmp/ultratex_dryrun.txt 2>&1 || true
    if ! "$PY" - "$SNAP_BEFORE" <<'PYCHECK'
import re, sys
text = open("/tmp/ultratex_dryrun.txt", errors="ignore").read()
m = re.search(r"Would install (.*)", text)
would = m.group(1).split() if m else []
norm = lambda n: n.lower().replace("_", "-")
have = {norm(l.split("==")[0]) for l in open(sys.argv[1], errors="ignore") if "==" in l}
changed = [w for w in would if norm(w.rsplit("-", 1)[0]) in have]
print("pip would add:", " ".join(would) or "(nothing)")
if changed:
    print("pip would CHANGE installed packages:", " ".join(changed))
sys.exit(1 if changed else 0)
PYCHECK
    then
        echo "Installing $MISSING would change packages that are already installed. Nothing was installed."
        echo "Install them yourself if you accept that:  $PY -m pip install $MISSING"
        exit 1
    fi
    # shellcheck disable=SC2086
    "$PY" -m pip install $MISSING
fi

# 3. models
get_file() {  # folder, name, url, sha256 or ""
    local dir="$1" name="$2" url="$3" sha="$4"
    if [ -f "$dir/$name" ]; then echo "Kept $name"; return 0; fi
    mkdir -p "$dir"
    echo "Downloading $name ..."
    curl -L --fail -# -o "$dir/$name.part" "$url"
    if [ -n "$sha" ]; then
        echo "$sha  $dir/$name.part" | sha256sum -c --quiet - || { echo "$name does not match the tested file. Not kept."; rm -f "$dir/$name.part"; return 1; }
    fi
    mv "$dir/$name.part" "$dir/$name"
    echo "Added $name"
}
if [ "$NO_MODELS" = 1 ]; then
    echo "--no-models: no model downloaded. The files UltraTex needs are listed in README.md."
else
    M="$COMFY/models"
    get_file "$M/vae" "flux2-vae.safetensors" "$COMFYORG/vae/flux2-vae.safetensors" ""
    get_file "$M/text_encoders" "$QWEN_FILE" "$QWEN_URL" "$QWEN_SHA"
    get_file "$M/loras" "ultratex_flux2.safetensors" "$UTX/flux2/lora/dit_lora.safetensors" "$LORA_SHA"
    get_file "$M/ultratex" "ultratex_flux2_decoder.pt" "$UTX/flux2/decoder.pt" "$DEC_SHA"
    if [ -f "$M/diffusion_models/$KLEIN_FILE" ]; then
        echo "Kept $KLEIN_FILE"
    else
        echo
        echo "LICENCE NOTICE - FLUX.2 klein base 9B"
        echo "UltraTex paints with FLUX.2 klein base 9B (Black Forest Labs), here as a GGUF file published by unsloth."
        echo "The model is under the FLUX Non-Commercial License: https://huggingface.co/black-forest-labs/FLUX.2-klein-base-9B"
        echo "Read it yourself before you use the model or its results for paid work."
        read -r -p "Download it now (5.2 GB)? [y/N] " answer
        if [ "${answer:-n}" = "y" ] || [ "${answer:-n}" = "Y" ]; then
            get_file "$M/diffusion_models" "$KLEIN_FILE" "$KLEIN_URL" "$KLEIN_SHA"
        else
            echo "Skipped. Download $KLEIN_FILE yourself into $M/diffusion_models"
        fi
    fi
fi

"$PY" -m pip freeze > "$SNAP_AFTER"
echo
echo "Added or changed packages:"
diff "$SNAP_BEFORE" "$SNAP_AFTER" | grep '^>' || echo "  none"
echo
echo "Done. HOW TO UNDO: close ComfyUI, delete $NODE (and ComfyUI-GGUF if nothing else uses it), uninstall the packages listed above with"
echo "  $PY -m pip uninstall NAME"
echo "and delete the UltraTex models in $COMFY/models if you want (flux2-vae, $QWEN_FILE, ultratex_flux2*, $KLEIN_FILE)."
