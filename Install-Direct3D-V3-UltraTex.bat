@echo off
setlocal
title PixelArtistry - Direct3D-V3 + UltraTex Installer
chcp 65001 >nul

rem ==========================================================================
rem  Direct3D-V3 + UltraTex installer for ComfyUI (Windows, Easy-Install / portable)
rem  by PixelArtistry
rem
rem  Installs four things, each only if it is not there yet:
rem    1. Direct3D-V3 nodes  Mstafa-awad/Direct3D-V3_Comfyui_Nodes (cu128 INT8 v2 build, MIT),
rem                          pinned to the tested commit and checked by SHA-256
rem    2. UltraTex nodes     Mstafa-awad/UltraTex-ComfyUI-nodes ("UltraTex Modular", GPL-3.0), pinned commit,
rem                          and city96/ComfyUI-GGUF (Apache-2.0) for its GGUF model loaders
rem    3. WTiVo nodes        Mstafa-awad/WTiVo-WatertightVoxel-ComfyuiNode (GPL-3.0-or-later), pinned commit
rem    4. Models             Direct3D-V3 INT8 stages (MostAadTech/Direct3D-V3-INT8, MIT),
rem                          DINOv3 ViT-H+ (Meta, DINOv3 License, GATED),
rem                          UltraTex LoRA + decoder (Yibo-Zhang/UltraTex on ModelScope),
rem                          FLUX.2 VAE (Comfy-Org/flux2-klein-9B),
rem                          FLUX.2 klein base 9B Q4_0 GGUF (unsloth; FLUX Non-Commercial License),
rem                          Qwen3-8B Q6_K GGUF text encoder (unsloth, Apache-2.0)
rem
rem  Direct3D-V3 runs in a PRIVATE Python environment inside its node folder
rem  (.runtime). UltraTex and WTiVo run in ComfyUI's Python; for them this
rem  installer adds only packages that are missing (trimesh, moderngl, glcontext,
rem  scipy, einops, psutil, threadpoolctl, gguf) and never changes a version that
rem  is already installed. It never installs or changes Triton; it only tells you
rem  if Triton is missing. It saves the package list before and after and shows
rem  what was added.
rem
rem  Needs: NVIDIA RTX card, 64-bit Python 3.12 installed on the PC (python.org,
rem  with the "py" launcher), ComfyUI with Python 3.12 and PyTorch 2.8 + CUDA 12.8,
rem  about 30 GB free disk space for everything, internet.
rem
rem  Run it from one of these places:
rem    - ComfyUI-Easy-Install\Add-Ons\<any folder>\
rem    - ComfyUI-Easy-Install\Add-Ons\
rem    - the folder that contains "python_embeded" and "ComfyUI"
rem  Close ComfyUI first. Safe to run twice: what is already there is kept.
rem
rem  Options (any order):
rem    NoPause   no questions (1536 stage only) and no pause at the end; needs a
rem              Hugging Face token in HF_TOKEN or a saved login for the gated models
rem    NoModels  install nodes and environments only, download no model at all
rem              (without options, the installer asks the same thing at the start)
rem
rem  TESTED ON: Windows 11, RTX 5080 16 GB, 48 GB RAM, embedded Python 3.12.10,
rem  PyTorch 2.8.0+cu128, ComfyUI 0.45.4. See README.md for what exactly was tested.
rem  NOT TESTED: the model downloads of this version, other GPUs, a PC without
rem  Python 3.12, a first-time Hugging Face login, Windows 10, WTiVo on cards
rem  older than the RTX 50 series (see the note the installer prints).
rem ==========================================================================

set "NOPAUSE="
set "NOMODELS="
for %%A in (%*) do (
    if /i "%%~A"=="NoPause" set "NOPAUSE=1"
    if /i "%%~A"=="NoModels" set "NOMODELS=1"
)

set "COMMIT=bb4cdc9ef50b00e5278b9755cb777c4a46a017ad"
set "ZIP_NAME=ComfyUI-Direct3D-V3-Windows-cu128_int8_v2.zip"
set "ZIP_URL=https://github.com/Mstafa-awad/Direct3D-V3_Comfyui_Nodes/raw/%COMMIT%/%ZIP_NAME%"
set "ZIP_SHA=d377591ad4414ed6a3999abe4ae96f24e28f8134cc8202e753a017f52a9c06d6"
set "NODE_NAME=ComfyUI-Direct3D-V3"
set "TESTED_COMFY=0.45.4"
set "DINO_PAGE=https://huggingface.co/facebook/dinov3-vith16plus-pretrain-lvd1689m"
set "UT_NAME=comfyui_ultratex_modular"
set "UT_COMMIT=4dea3ff0c61e0ec0aa82808ffe2299f14089db92"
set "UT_URL=https://github.com/Mstafa-awad/UltraTex-ComfyUI-nodes/archive/%UT_COMMIT%.zip"
set "GG_NAME=ComfyUI-GGUF"
set "GG_COMMIT=4dfc025e4be06ba9c210bd1189546f7af67f445d"
set "GG_URL=https://github.com/city96/ComfyUI-GGUF/archive/%GG_COMMIT%.zip"
set "WT_NAME=WTiVo-WatertightVoxel-ComfyuiNode"
set "WT_COMMIT=fb9e9ea6a7deec965d3a4bf43ba7a4a9ff3856f3"
set "WT_URL=https://github.com/Mstafa-awad/WTiVo-WatertightVoxel-ComfyuiNode/archive/%WT_COMMIT%.zip"
set "KLEIN_PAGE=https://huggingface.co/black-forest-labs/FLUX.2-klein-base-9B"
set "KLEIN_FILE=flux-2-klein-base-9b-Q4_0.gguf"
set "KLEIN_URL=https://huggingface.co/unsloth/FLUX.2-klein-base-9B-GGUF/resolve/62ede6c5d20015b63112603ae59b556ca75f5bc9/flux-2-klein-base-9b-Q4_0.gguf"
set "KLEIN_SHA=02d4c2b55b5a6d4aca65eafd0f0eabe8c1e3837391042b6879be04eb99c7e116"
set "QWEN_FILE=Qwen3-8B-Q6_K.gguf"
set "QWEN_URL=https://huggingface.co/unsloth/Qwen3-8B-GGUF/resolve/a6adef130ffb23ddaf1a62fec9dced968c9bc482/Qwen3-8B-Q6_K.gguf"
set "QWEN_SHA=0eaec718fdeab0f429dfa0ec481c090388811f5e63785ddb582292f4ef3c3827"
set "COMFYORG=https://huggingface.co/Comfy-Org/flux2-klein-9B/resolve/1138ce884c8e977cdacacbe779784fec4426bb3f/split_files"
set "UTX=https://www.modelscope.ai/models/Yibo-Zhang/UltraTex/resolve/master"
set "LORA_SHA=3b1915177a81bc2ab43f501355bf39113df0128e6cbc6fedf8b8621d5e06a01c"
set "DEC_SHA=981dc4c52481687c6da4e6211617615a2b2bcc33456e1953ee6c5478aa00025b"

echo.
echo  ============================================================
echo    Direct3D-V3 + UltraTex for ComfyUI - installer by PixelArtistry
echo    Direct3D-V3, UltraTex Modular and WTiVo nodes by Mstafa-awad
echo  ============================================================
echo.

rem ---------------------------------------------------------------- 1. find ComfyUI
set "ROOT="
if exist "%~dp0python_embeded\python.exe" if exist "%~dp0ComfyUI\main.py" set "ROOT=%~dp0."
if not defined ROOT if exist "%~dp0..\python_embeded\python.exe" if exist "%~dp0..\ComfyUI\main.py" set "ROOT=%~dp0.."
if not defined ROOT if exist "%~dp0..\..\python_embeded\python.exe" if exist "%~dp0..\..\ComfyUI\main.py" set "ROOT=%~dp0..\.."
if not defined ROOT if exist "%~dp0..\..\..\python_embeded\python.exe" if exist "%~dp0..\..\..\ComfyUI\main.py" set "ROOT=%~dp0..\..\.."
if not defined ROOT (
    echo  [ERROR] Could not find "python_embeded" and "ComfyUI" near this file.
    echo          Put this folder into ComfyUI-Easy-Install\Add-Ons and run it again.
    goto :fail
)
for %%I in ("%ROOT%") do set "ROOT=%%~fI"
set "PY=%ROOT%\python_embeded\python.exe"
set "COMFY=%ROOT%\ComfyUI"
set "CN=%COMFY%\custom_nodes"
set "NODE_DIR=%CN%\%NODE_NAME%"
set "WORKER=%NODE_DIR%\.runtime\Scripts\python.exe"
set "MODELS=%NODE_DIR%\models\Direct3D-V3"
set "SNAP_BEFORE=%ROOT%\direct3d-v3_pip_before.txt"
set "SNAP_AFTER=%ROOT%\direct3d-v3_pip_after.txt"
set "UT_DIR=%CN%\%UT_NAME%"
set "GG_DIR=%CN%\%GG_NAME%"
set "WT_DIR=%CN%\%WT_NAME%"
set "CMODELS=%COMFY%\models"
set "UNZ=%COMFY%\_pixelartistry_install_tmp"
set "T=%TEMP%\d3dv3_install"
if not exist "%T%" mkdir "%T%"
echo  ComfyUI found: %COMFY%

rem ComfyUI must be closed. Port: the --port value in "Start ComfyUI.bat", else 8188.
set "PORT="
if exist "%T%\port.txt" del "%T%\port.txt"
if exist "%ROOT%\Start ComfyUI.bat" "%PY%" -I -c "import sys,re;t=open(sys.argv[1],errors='ignore').read();m=re.findall(r'^(?!\s*(?:rem|::)).*?--port[= ]+(\d+)',t,re.M|re.I);print(m[-1] if m else '')" "%ROOT%\Start ComfyUI.bat" > "%T%\port.txt" 2>nul
if exist "%T%\port.txt" set /p PORT=<"%T%\port.txt"
if not defined PORT set "PORT=8188"
netstat -ano | findstr /r /c:":%PORT% .*LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo.
    echo  [ERROR] ComfyUI seems to be running on port %PORT%. Close it first, then run this again.
    goto :fail
)

rem ---------------------------------------------------------------- 2. checks
echo.
echo  [1/9] Checking this PC...
where nvidia-smi >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] No NVIDIA driver found ^(nvidia-smi is missing^). Direct3D-V3 needs an NVIDIA RTX card.
    goto :fail
)
for /f "usebackq delims=" %%G in (`nvidia-smi --query-gpu^=name^,memory.total --format^=csv^,noheader`) do echo        GPU: %%G

set "SYSPY="
py -3.12 -c "import sys,sysconfig;sys.exit(0 if sysconfig.get_platform()=='win-amd64' else 1)" >nul 2>&1
if not errorlevel 1 set "SYSPY=py -3.12"
if defined SYSPY goto :syspy_done
python -c "import sys,sysconfig;sys.exit(0 if sys.version_info[:2]==(3,12) and sysconfig.get_platform()=='win-amd64' else 1)" >nul 2>&1
if not errorlevel 1 set "SYSPY=python"
:syspy_done
if not defined SYSPY (
    echo.
    echo  [ERROR] 64-bit Python 3.12 is not installed on this PC.
    echo          The node pack builds its own Python environment and needs it for that
    echo          ^(ComfyUI's embedded Python cannot create one^).
    echo          Install "Windows installer ^(64-bit^)" of Python 3.12 from
    echo            https://www.python.org/downloads/windows/
    echo          keep "py launcher" ticked, then run this installer again.
    goto :fail
)
echo        Python 3.12 for the worker environment: %SYSPY%

set "CV="
"%PY%" -I -c "import re,sys;t=open(sys.argv[1]).read();print(re.search(r'__version__\s*=\s*[\x22\x27]([^\x22\x27]+)',t).group(1))" "%COMFY%\comfyui_version.py" > "%T%\cv.txt" 2>nul
set /p CV=<"%T%\cv.txt"
if not defined CV (
    echo        ComfyUI version: unknown ^(tested with %TESTED_COMFY%^)
    goto :version_done
)
"%PY%" -I -c "import sys;f=lambda s:tuple(int(x) for x in s.split('-')[0].split('.')[:3]);sys.exit(0 if f(sys.argv[1])>=f(sys.argv[2]) else 1)" "%CV%" "%TESTED_COMFY%"
if errorlevel 1 (
    echo        WARNING - ComfyUI v%CV% is older than the tested v%TESTED_COMFY%.
    echo                  The nodes may work, but the workflow uses ComfyUI's newer 3D nodes.
    echo                  Update ComfyUI if the workflow shows missing nodes.
) else (
    echo        ComfyUI v%CV% ^(tested with %TESTED_COMFY%^)
)
:version_done

rem ---------------------------------------------------------------- 3. choices
set "STAGE=1536"
set "NEED_GB=30"
if defined NOPAUSE goto :stage_done
if defined NOMODELS goto :stage_done
echo.
echo        Models: Direct3D-V3 ^(about 5 GB^) and UltraTex ^(about 12 GB^).
echo        Models already in the folders this installer uses are never downloaded again.
echo        Models in other folders ^(extra_model_paths.yaml^) are not seen: choose 2 for those.
echo          1 = download the models that are missing  ^(recommended^)
echo          2 = skip all model downloads  ^(I have the models already^)
choice /c 12 /n /m "        Your choice [1/2] "
if errorlevel 2 (
    set "NOMODELS=1"
    goto :stage_done
)
echo.
echo        Which model stages?
echo          1 = 1536 only  ^(recommended; 1.3 GB + the 3.4 GB image encoder^)
echo          2 = 512, 1024 and 1536  ^(for cascade mode; 3.9 GB + the 3.4 GB image encoder^)
choice /c 12 /n /m "        Your choice [1/2] "
if errorlevel 2 (
    set "STAGE=all"
    set "NEED_GB=33"
)
:stage_done
"%PY%" -I -c "import shutil,sys;free=shutil.disk_usage(sys.argv[1]).free/2**30;print(f'       Free disk space on the ComfyUI drive: {free:.0f} GB (needed: about {sys.argv[2]} GB for a new install)');sys.exit(0 if free>=float(sys.argv[2]) else 1)" "%CN%" "%NEED_GB%"
if errorlevel 1 if not exist "%WORKER%" (
    echo  [ERROR] Not enough free disk space. Free some space and run this again.
    goto :fail
)

rem ---------------------------------------------------------------- 4. snapshot
echo.
echo  [2/9] Saving the package list of ComfyUI's Python...
if exist "%SNAP_BEFORE%" (
    echo        Kept the list from the first run: %SNAP_BEFORE%
) else (
    "%PY%" -I -m pip freeze > "%SNAP_BEFORE%" 2>nul
    echo        Saved: %SNAP_BEFORE%
)

rem ---------------------------------------------------------------- 5. nodes
echo.
echo  [3/9] Direct3D-V3 node pack ^(commit %COMMIT:~0,7%^)...
if exist "%NODE_DIR%\nodes.py" (
    echo        Already installed - left as it is: %NODE_DIR%
    goto :nodes_done
)
if exist "%NODE_DIR%" (
    echo  [ERROR] %NODE_DIR% exists but is not a complete install.
    echo          Rename or delete that folder yourself, then run this again.
    goto :fail
)
curl -L --fail -s -o "%T%\%ZIP_NAME%" "%ZIP_URL%"
if errorlevel 1 (
    echo  [ERROR] Download of the node pack failed. Check your internet connection.
    goto :fail
)
"%PY%" -I -c "import hashlib,sys;sys.exit(0 if hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest()==sys.argv[2] else 1)" "%T%\%ZIP_NAME%" "%ZIP_SHA%"
if errorlevel 1 (
    echo  [ERROR] The downloaded node pack does not match the tested file ^(SHA-256^). Nothing was installed.
    del "%T%\%ZIP_NAME%"
    goto :fail
)
rem Unpack on the ComfyUI drive: "move" cannot move a folder to another drive.
if exist "%UNZ%" rmdir /s /q "%UNZ%"
mkdir "%UNZ%"
tar -xf "%T%\%ZIP_NAME%" -C "%UNZ%"
if not exist "%UNZ%\%NODE_NAME%\nodes.py" (
    echo  [ERROR] The node pack archive has an unexpected layout. Nothing was installed.
    rmdir /s /q "%UNZ%"
    goto :fail
)
move "%UNZ%\%NODE_NAME%" "%NODE_DIR%" >nul
rmdir /s /q "%UNZ%"
if not exist "%NODE_DIR%\nodes.py" (
    echo  [ERROR] Could not move the node pack into custom_nodes.
    goto :fail
)
echo        Installed: %NODE_DIR%
:nodes_done

rem ---------------------------------------------------------------- 6. runtime and models
echo.
echo  [4/9] Direct3D-V3 worker environment and models...
set "HAVE_RT="
if exist "%WORKER%" "%WORKER%" -c "import torch,triton,transformers,trimesh" >nul 2>&1
if exist "%WORKER%" if not errorlevel 1 set "HAVE_RT=1"
set "HAVE_MODELS=1"
if not exist "%MODELS%\model_index.json" set "HAVE_MODELS="
if not exist "%MODELS%\image_encoder\model.safetensors" set "HAVE_MODELS="
if not exist "%MODELS%\shape_transformers_1536\model.safetensors" set "HAVE_MODELS="
if "%STAGE%"=="all" if not exist "%MODELS%\shape_transformers_512\model.safetensors" set "HAVE_MODELS="
if "%STAGE%"=="all" if not exist "%MODELS%\shape_transformers_1024\model.safetensors" set "HAVE_MODELS="
if defined HAVE_RT if defined HAVE_MODELS (
    echo        Already complete - nothing to download.
    goto :setup_done
)
if defined NOMODELS if not defined HAVE_MODELS call :d3d_model_hint
if defined NOMODELS if defined HAVE_RT (
    echo        Worker environment is there. No model downloaded.
    goto :setup_done
)
if defined NOMODELS (
    set "HAVE_MODELS=1"
    echo        Building the worker environment only, no model download.
)
if defined HAVE_MODELS goto :run_setup
echo.
echo        LICENCE NOTICE
echo        Direct3D-V3, its INT8 weights and these nodes are MIT licensed. The image encoder DINOv3 is
echo        under Meta's DINOv3 License and is gated on Hugging Face:
echo          1. Open %DINO_PAGE%
echo          2. Sign in, read the licence and request access. Approval is manual and can take a while.
echo          3. Create a token with "Read" permission ^(Settings ^> Access Tokens^).
echo        The setup asks for the token if this PC has no saved login. It is stored by
echo        Hugging Face's own tool in your user folder, not by this installer.
echo.
if defined NOPAUSE goto :run_setup
choice /c YN /n /m "        Do you have access to DINOv3 and want to continue? [Y/N] "
if errorlevel 2 (
    echo        Stopped before the downloads. Run this installer again once you have access.
    goto :fail
)
:run_setup
set "SETUP_ARGS=--stage %STAGE%"
if defined HAVE_RT set "SETUP_ARGS=--models-only --stage %STAGE%"
if defined HAVE_MODELS set "SETUP_ARGS=--runtime-only"
echo        Running the pack's setup ^(%SETUP_ARGS%^). This takes a while...
%SYSPY% "%NODE_DIR%\setup_windows.py" %SETUP_ARGS%
if errorlevel 1 (
    echo.
    echo  [ERROR] The pack's setup failed. Read the messages above.
    echo          Common causes: no access to DINOv3 yet, no internet, not enough disk space.
    echo          Run this installer again to continue; finished parts are kept.
    goto :fail
)
:setup_done

rem ---------------------------------------------------------------- 7. UltraTex and WTiVo node packs
echo.
echo  [5/9] UltraTex Modular node pack ^(commit %UT_COMMIT:~0,7%^) and ComfyUI-GGUF...
call :get_pack "%UT_NAME%" "%UT_DIR%" "%UT_URL%" "UltraTex-ComfyUI-nodes-%UT_COMMIT%" "extension.py"
if errorlevel 1 goto :fail
call :get_pack "%GG_NAME%" "%GG_DIR%" "%GG_URL%" "%GG_NAME%-%GG_COMMIT%" "nodes.py"
if errorlevel 1 goto :fail
echo.
echo  [6/9] WTiVo node pack ^(commit %WT_COMMIT:~0,7%^)...
call :get_pack "%WT_NAME%" "%WT_DIR%" "%WT_URL%" "%WT_NAME%-%WT_COMMIT%" "comfy_node.py"
if errorlevel 1 goto :fail
echo        NOTE - WTiVo ships binaries for RTX 50-series cards. On an RTX 20, 30 or 40 card, extract
echo               the "ForNonBlackwellgpu" archive inside its "build" folder ^(see its README^).

echo.
echo  [7/9] Python packages for UltraTex and WTiVo ^(only what is missing^)...
"%PY%" -I -c "import sys,torch;v=sys.version_info[:2];print('       ComfyUI Python %%d.%%d, PyTorch %%s'%%(v[0],v[1],torch.__version__));sys.exit(0 if v==(3,12) else 3)"
if errorlevel 3 echo        WARNING - WTiVo's binaries are built for Python 3.12. They will not load in this ComfyUI.
"%PY%" -I -c "import importlib.util as u,sys;sys.exit(0 if u.find_spec('triton') else 4)"
if errorlevel 4 (
    echo        WARNING - Triton is not installed in ComfyUI's Python. UltraTex needs it for its sparse generation.
    echo                  This installer does not install Triton, because its version must match your PyTorch.
    echo                  See the README of the UltraTex pack for the Windows pairing.
)
"%PY%" -I -c "import importlib.util as u;print(' '.join(p for p in ('trimesh','moderngl','glcontext','scipy','einops','psutil','threadpoolctl','gguf') if u.find_spec(p) is None))" > "%T%\missing.txt" 2>nul
set "MISSING="
set /p MISSING=<"%T%\missing.txt"
if not defined MISSING (
    echo        Nothing missing.
    goto :pip_done
)
echo        Missing: %MISSING%
"%PY%" -I -m pip install --only-binary=:all: --dry-run %MISSING% > "%T%\dryrun.txt" 2>&1
"%PY%" -I -c "import re,sys;t=open(sys.argv[1],errors='ignore').read();m=re.search(r'Would install (.*)',t);w=m.group(1).split() if m else [];norm=lambda n:n.lower().replace('_','-');have={norm(l.split('==')[0]) for l in open(sys.argv[2],errors='ignore') if '==' in l};chg=[x for x in w if norm(x.rsplit('-',1)[0]) in have];print('       pip would add:',' '.join(w) or '(nothing)');chg and print('       pip would CHANGE installed packages:',' '.join(chg));sys.exit(1 if chg else 0)" "%T%\dryrun.txt" "%SNAP_BEFORE%"
if errorlevel 1 (
    echo  [ERROR] Installing %MISSING% would change packages that are already installed.
    echo          Nothing was installed. Install them yourself if you accept that change:
    echo            "%PY%" -m pip install %MISSING%
    goto :fail
)
"%PY%" -I -m pip install --only-binary=:all: %MISSING%
if errorlevel 1 (
    echo  [ERROR] pip could not install: %MISSING%
    goto :fail
)
:pip_done

rem ---------------------------------------------------------------- 8. UltraTex models
echo.
echo  [8/9] UltraTex models...
if defined NOMODELS (
    echo        Model download skipped. UltraTex needs these files in %CMODELS%:
    echo          vae\flux2-vae.safetensors
    echo          text_encoders\%QWEN_FILE%
    echo          loras\ultratex_flux2.safetensors
    echo          ultratex\ultratex_flux2_decoder.pt
    echo          diffusion_models\%KLEIN_FILE%
    echo        Folders you set in extra_model_paths.yaml work too.
    goto :ut_models_done
)
call :get_file "%CMODELS%\vae" "flux2-vae.safetensors" "%COMFYORG%/vae/flux2-vae.safetensors" ""
if errorlevel 1 goto :fail
call :get_file "%CMODELS%\text_encoders" "%QWEN_FILE%" "%QWEN_URL%" "%QWEN_SHA%"
if errorlevel 1 goto :fail
call :get_file "%CMODELS%\loras" "ultratex_flux2.safetensors" "%UTX%/flux2/lora/dit_lora.safetensors" "%LORA_SHA%"
if errorlevel 1 goto :fail
call :get_file "%CMODELS%\ultratex" "ultratex_flux2_decoder.pt" "%UTX%/flux2/decoder.pt" "%DEC_SHA%"
if errorlevel 1 goto :fail
if exist "%CMODELS%\diffusion_models\%KLEIN_FILE%" (
    echo        Kept %KLEIN_FILE%
    goto :ut_models_done
)
echo.
echo        LICENCE NOTICE - FLUX.2 klein base 9B
echo        UltraTex paints with FLUX.2 klein base 9B from Black Forest Labs, here as a GGUF file
echo        published by unsloth. The model is under the FLUX Non-Commercial License:
echo          %KLEIN_PAGE%
echo        Read the licence yourself before you use the model or its results for paid work.
echo.
if defined NOPAUSE goto :klein_get
choice /c YN /n /m "        Download it now (5.2 GB)? [Y/N] "
if errorlevel 2 (
    echo        Skipped. Download %KLEIN_FILE% yourself into
    echo          %CMODELS%\diffusion_models
    goto :ut_models_done
)
:klein_get
call :get_file "%CMODELS%\diffusion_models" "%KLEIN_FILE%" "%KLEIN_URL%" "%KLEIN_SHA%"
if errorlevel 1 goto :fail
:ut_models_done

rem ---------------------------------------------------------------- 7. verify
echo.
echo  [9/9] Checking the install...
"%WORKER%" -c "import torch,triton;print('       Direct3D-V3 worker: PyTorch',torch.__version__,'| Triton',triton.__version__,'| CUDA available:',torch.cuda.is_available())"
if errorlevel 1 (
    echo  [ERROR] The worker environment does not start. Delete "%NODE_DIR%\.runtime" and run this again.
    goto :fail
)
"%PY%" -I -c "import importlib.util as u;m=[p for p in ('trimesh','moderngl','glcontext','scipy','einops','psutil','threadpoolctl','gguf') if u.find_spec(p) is None];print('       UltraTex / WTiVo packages:','all present' if not m else 'MISSING '+' '.join(m))"
if not exist "%UT_DIR%\extension.py" echo        WARNING - UltraTex Modular nodes are missing.
if not exist "%GG_DIR%\nodes.py" echo        WARNING - ComfyUI-GGUF nodes are missing.
if not exist "%WT_DIR%\comfy_node.py" echo        WARNING - WTiVo nodes are missing.
"%PY%" -I -m pip freeze > "%SNAP_AFTER%" 2>nul
fc "%SNAP_BEFORE%" "%SNAP_AFTER%" >nul 2>&1
if errorlevel 1 (
    echo        ComfyUI's package list changed. Added or changed lines:
    "%PY%" -I -c "import sys;a=set(open(sys.argv[1],errors='ignore').read().split());[print('         +',l) for l in open(sys.argv[2],errors='ignore').read().split() if l not in a]" "%SNAP_BEFORE%" "%SNAP_AFTER%"
    echo        Full lists: %SNAP_BEFORE%
    echo                    %SNAP_AFTER%
) else (
    echo        ComfyUI's own Python packages: unchanged.
)

rem ---------------------------------------------------------------- 8. workflows
echo.
echo  Workflows...
set "WF_SRC="
if exist "%~dp0workflows\PixelArtistry_Direct3D_01_Default.json" set "WF_SRC=%~dp0workflows"
if not defined WF_SRC if exist "%~dp0..\workflows\PixelArtistry_Direct3D_01_Default.json" set "WF_SRC=%~dp0..\workflows"
set "WF_DST=%COMFY%\user\default\workflows\PixelArtistry\Direct3D-V3"
if not defined WF_SRC (
    echo        No workflows folder next to this installer - skipped.
    goto :workflows_done
)
if not exist "%WF_DST%" mkdir "%WF_DST%"
for %%F in ("%WF_SRC%\*.json") do call :copy_workflow "%%~fF" "%%~nxF"
:workflows_done

rem ---------------------------------------------------------------- summary
echo.
echo  ============================================================
echo    Done. Start ComfyUI, open the Workflows list, then the folder
echo    PixelArtistry ^> Direct3D-V3 and "PixelArtistry_Direct3D_01_Default".
echo  ============================================================
echo.
echo    The image-to-3D part of the workflows uses ComfyUI's own TRELLIS.2 nodes
echo    and their models; the max-detail workflow also uses Qwen Image 2.1. If a
echo    model is missing, ComfyUI lists it when you load the workflow.
echo    One node in the workflows comes from ComfyUI-KJNodes; install it with
echo    ComfyUI Manager if ComfyUI reports it missing.
echo.
echo    Results are saved to ComfyUI\output\Direct3D-V3.
echo.
echo    HOW TO UNDO
echo      1. Close ComfyUI.
echo      2. Delete these folders ^(the first holds Direct3D-V3's worker
echo         environment and models^):
echo           %NODE_DIR%
echo           %UT_DIR%
echo           %WT_DIR%
echo         ComfyUI-GGUF is shared with other workflows; delete it only if you do not use it elsewhere:
echo           %GG_DIR%
echo      2b. Packages this installer added to ComfyUI's Python are the "+" lines
echo          above. Remove one with:  "%PY%" -m pip uninstall NAME
echo          UltraTex models are in %CMODELS%:
echo          flux2-vae, %QWEN_FILE%, ultratex_flux2*, %KLEIN_FILE%
echo      3. Optional: delete the workflows this installer added in
echo           %WF_DST%
echo         and the two package lists direct3d-v3_pip_*.txt in
echo           %ROOT%
echo      Nothing else was changed. A Hugging Face login stays saved in your
echo      user folder; remove it with "hf auth logout" if you want.
echo.
if not defined NOPAUSE pause
exit /b 0

:fail
echo.
echo  Installation stopped.
echo.
if not defined NOPAUSE pause
exit /b 1

rem ==========================================================================
:d3d_model_hint
echo        Model download skipped. Direct3D-V3 looks for its models here:
echo          %MODELS%
echo        It needs model_index.json, image_encoder\ and shape_transformers_1536\
echo        ^(plus shape_transformers_512\ and _1024\ for cascade mode^).
echo        Copy them there from your earlier install, or run this installer again
echo        and choose 1 to download what is missing.
exit /b 0

rem ==========================================================================
:copy_workflow
rem %1 = source file, %2 = file name. Never overwrites a workflow that is already there.
if exist "%WF_DST%\%~2" (
    echo        Kept your existing %~2
) else (
    copy /y "%~1" "%WF_DST%\%~2" >nul
    echo        Added %~2
)
exit /b 0

rem ==========================================================================
:get_pack
rem %1 = name, %2 = target folder, %3 = archive URL, %4 = folder name inside the archive, %5 = file that proves a complete install
if exist "%~2\%~5" (
    echo        Already installed - left as it is: %~2
    exit /b 0
)
if exist "%~2" (
    echo  [ERROR] %~2 exists but is not a complete install.
    echo          Rename or delete that folder yourself, then run this again.
    exit /b 1
)
curl -L --fail -s -o "%T%\%~1.zip" "%~3"
if errorlevel 1 (
    echo  [ERROR] Download of %~1 failed. Check your internet connection.
    exit /b 1
)
rem Unpack on the ComfyUI drive: "move" cannot move a folder to another drive.
if exist "%UNZ%" rmdir /s /q "%UNZ%"
mkdir "%UNZ%"
tar -xf "%T%\%~1.zip" -C "%UNZ%"
if not exist "%UNZ%\%~4\%~5" (
    echo  [ERROR] The archive of %~1 has an unexpected layout. Nothing was installed.
    rmdir /s /q "%UNZ%"
    exit /b 1
)
move "%UNZ%\%~4" "%~2" >nul
rmdir /s /q "%UNZ%"
if not exist "%~2\%~5" (
    echo  [ERROR] Could not move %~1 into custom_nodes.
    exit /b 1
)
echo        Installed: %~2
exit /b 0

rem ==========================================================================
:get_file
rem %1 = target folder, %2 = file name, %3 = URL, %4 = SHA-256 or empty. Keeps a file that is already there.
if exist "%~1\%~2" (
    echo        Kept %~2
    exit /b 0
)
if not exist "%~1" mkdir "%~1"
echo        Downloading %~2 ...
curl -L --fail -# -o "%~1\%~2.part" "%~3"
if errorlevel 1 (
    echo  [ERROR] Download of %~2 failed.
    if exist "%~1\%~2.part" del "%~1\%~2.part"
    exit /b 1
)
if "%~4"=="" goto :get_file_ok
"%PY%" -I -c "import hashlib,sys;h=hashlib.sha256();f=open(sys.argv[1],'rb');[h.update(b) for b in iter(lambda:f.read(1<<20),b'')];sys.exit(0 if h.hexdigest()==sys.argv[2] else 1)" "%~1\%~2.part" "%~4"
if errorlevel 1 (
    echo  [ERROR] %~2 does not match the tested file ^(SHA-256^). It was not kept.
    del "%~1\%~2.part"
    exit /b 1
)
:get_file_ok
move "%~1\%~2.part" "%~1\%~2" >nul
echo        Added %~2
exit /b 0
