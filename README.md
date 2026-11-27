# Direct3D-V3 + UltraTex for ComfyUI - sharp, textured 3D models from one image

Turns **one image** into a **detailed, textured 3D model**, free and local in ComfyUI: TRELLIS.2 builds the coarse model, **Direct3D-V3** refines it at 1536, **UltraTex** paints it.

![The same dwarf: TRELLIS.2 coarse mesh (left) and after the max-detail Direct3D-V3 workflow (right)](docs/images/dwarf_before_after.jpg)

This pack is the installer and the workflows from my video. Everything here was measured on one PC: **RTX 5080 16 GB, 48 GB RAM, Windows 11, ComfyUI 0.45.4**. What was not tested is listed at the end; please read it.

## Which workflow?

All of them share one canvas: image > TRELLIS.2 > cleanup switch (WTiVo or remesh twice) > Direct3D-V3 > 3D previews > UltraTex texture stage. Do not want a texture? Select groups 7 to 9 and bypass them.

| Workflow | What is different |
|---|---|
| **PixelArtistry_Direct3D_01_Default** | The standard pipeline: WTiVo cleanup, Direct3D-V3 cascade with 16 steps, UltraTex texture. **Start here.** |
| **PixelArtistry_Direct3D_02_Max_Detail** | Most detail: clay version of your image as the reference (Qwen Image 2.1), raw coarse mesh, single stage, 16 steps, `fdg` guidance at 9. Needs the Qwen Image 2.1 models. |
| **PixelArtistry_Direct3D_03_Multiview** | Adds back, left and right images for Direct3D-V3. |
| **PixelArtistry_Direct3D_04_Low_Poly** | Decimates to 20,000 triangles before texturing: a game-ready character. |
| **PixelArtistry_Direct3D_05_Low_VRAM** | `max_tokens` at 75,000 and the texture stage bypassed; the note lists the value per card size. |
| **PixelArtistry_Direct3D_06_Your_Mesh** | Refine a mesh that is already on disk. Direct3D-V3 only. |

> **State:** workflows 1 to 5 were assembled from the tested workflows by script on 27 November and have **not been opened in ComfyUI or run yet**. The set of 26 November is in the history (commit `d859f8a`).

Workflows 1 to 5 need Direct3D-V3, UltraTex and WTiVo (this installer) plus two helper packs this installer does **not** install, because their requirements touch packages many other nodes share (OpenCV): [visualbruno/ComfyUI-Trellis2](https://github.com/visualbruno/ComfyUI-Trellis2) (two utility nodes) and [kijai/ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) (one node). Install them with ComfyUI Manager if ComfyUI reports missing nodes.

The image-to-3D part uses **ComfyUI's own TRELLIS.2 nodes** and their models.

## Results

![Dwarf: TRELLIS.2, Hi3D and Direct3D-V3 side by side](docs/images/three_way_dwarf.jpg)

Direct3D-V3 stays faithful to your image (faces, expressions, flat panels) and with default settings was 3 to 5 times faster than Hi3D on the same models (64 to 222 s against 5.5 to 16 minutes). Hi3D adds detail that is not in the image, repairs broken areas and gives a closed mesh. On a monster and a robot Hi3D was clearly ahead:

![Robot: TRELLIS.2, Hi3D and Direct3D-V3 side by side](docs/images/three_way_robot.jpg)

![Maximum detail: what the settings do](docs/images/max_detail_settings.jpg)

![Textured with UltraTex](docs/images/textured.jpg)

## Install (Windows)

1. Install [ComfyUI-Easy-Install](https://github.com/Tavris1/ComfyUI-Easy-Install) if you don't have it yet. Your ComfyUI must run **Python 3.12 with PyTorch 2.8 + CUDA 12.8**.
2. Install **64-bit Python 3.12** from [python.org](https://www.python.org/downloads/windows/) and keep "py launcher" ticked. Direct3D-V3 builds its own Python environment with it, so ComfyUI's packages stay untouched.
3. Request access to the two gated models on Hugging Face (free, but needs an account):
   - [DINOv3 ViT-H+](https://huggingface.co/facebook/dinov3-vith16plus-pretrain-lvd1689m) for Direct3D-V3. **Approval is manual and can take a while. Do this first.**
   - [FLUX.2 klein base 9B fp8](https://huggingface.co/black-forest-labs/FLUX.2-klein-base-9b-fp8) for UltraTex.
4. On this page: **Code > Download ZIP**. Unzip it into `ComfyUI-Easy-Install\Add-Ons\`.
5. Close ComfyUI and double-click `Install-Direct3D-V3-UltraTex.bat`.

Other portable installs: put the unzipped folder next to `python_embeded` and run the `.bat` there.

### What the installer does

- Checks the GPU, Python 3.12, your ComfyUI version and free disk space.
- Saves the package list of ComfyUI's Python before and after, and shows what was added.
- **Direct3D-V3 nodes** ([Mstafa-awad/Direct3D-V3_Comfyui_Nodes](https://github.com/Mstafa-awad/Direct3D-V3_Comfyui_Nodes), build of 26 November 2026): pinned commit, checked by SHA-256. Its own setup builds a private environment inside the node folder (about 7.6 GB) and downloads the INT8 weights (1.3 GB per stage) and DINOv3 (3.4 GB).
- **UltraTex nodes** ([visualbruno/ComfyUI-UltraTex](https://github.com/visualbruno/ComfyUI-UltraTex)) and **WTiVo nodes** ([Mstafa-awad/WTiVo-WatertightVoxel-ComfyuiNode](https://github.com/Mstafa-awad/WTiVo-WatertightVoxel-ComfyuiNode)): pinned commits.
- Adds `trimesh`, `moderngl`, `xatlas` and `scipy` to ComfyUI's Python **only if they are missing**. It does a dry run first and stops if pip would change a package you already have.
- **UltraTex models:** FLUX.2 VAE (0.3 GB), Qwen3 8B text encoder (8.1 GB), UltraTex LoRA (0.5 GB) and decoder (0.1 GB), and FLUX.2 klein base 9B fp8 (8.9 GB, with your own Hugging Face login after you accepted its licence). Files that are already in `ComfyUI\models` are kept.
- Copies the workflows into `ComfyUI\user\default\workflows`. It never overwrites a workflow that is already there.
- Safe to run twice. Prints how to undo everything at the end.

Options: `Install-Direct3D-V3-UltraTex.bat NoModels` installs nodes and environments without downloading any model; `NoPause` runs without questions.

**WTiVo on RTX 20 / 30 / 40 cards:** the pack ships binaries for the RTX 50 series. On older cards, extract the "ForNonBlackwellgpu" archive inside its `build` folder, as its README describes.

## Linux

**Direct3D-V3 cannot be installed on Linux with this node pack today.** It is Windows-only: it ships a compiled Windows voxelizer and its setup refuses other systems. WTiVo ships Windows binaries too.

`install_ultratex_linux.sh` installs the texturing half (UltraTex nodes and models) on Linux. **It has not been tested**; I have no Linux machine with an NVIDIA card. It follows the same steps as the Windows installer. Read it before you run it, and tell me in the issues what happened.

## How much VRAM

VRAM used by the Direct3D-V3 step alone. It follows the size of the model (the token count), not the resolution setting.

| Run | Tokens | VRAM reserved by Direct3D-V3 | RAM |
|---|---|---|---|
| Small character | 77,000 | 7.7 GB | 13.6 GB |
| Robot | 106,000 | 9.5 GB | 17.4 GB |
| Large model at the limit | 169,000 | 13.6 GB | 21.6 GB |
| 12 GB software limit, `max_tokens` 120,000 | 120,000 | 10.3 GB | 18.3 GB |
| 8 GB software limit, `max_tokens` 75,000 | 74,000 | 7.4 GB | 13.4 GB |
| 6 GB software limit, `max_tokens` 50,000 | 49,000 | 5.9 GB | 11.9 GB |

The limits were held by a second program on my 16 GB card. That is a software limit, **not a real smaller card**. Lowering `max_tokens` scales big models down, so they lose detail. TRELLIS.2 and UltraTex were not tested under a limit; UltraTex used 14.5 GB on my card. With TRELLIS.2 in the same run, system RAM peaked at 42 to 45 GB of my 48 GB.

## Settings that matter

| Setting | Value | Why |
|---|---|---|
| `max_tokens` + `token_fit` | 150,000, `shrink_to_fit` | The node's old default (50,000, preserve scale) refuses normal TRELLIS.2 meshes. This is also the VRAM dial. |
| `stage_mode` | `single_stage` for detail, `cascade` for a clean mesh | Cascade left 416 open edges instead of 34,282 on my test character, but simplified fine detail. |
| `steps` | 8, or 16 for maximum detail | 16 halved the loose pieces for almost double the time. 25 gave artefacts around the eyes. |
| `guidance_mode` | `fdg` with `fdg_high_scale` 9 for maximum detail | Slightly crisper at the same speed. |
| `accel_mode` | `lossless` | 2.8 times faster than `off`. `fast` was slower on my card. |

About the coarse mesh: a 512 mesh worked almost as well as a 1024 one, but the shapes must be there. Direct3D-V3 refines what the mesh has and does not rebuild what is missing. Cleaning the mesh first (remesh, WTiVo) gives a much cleaner result and costs some detail; on hard-surface models the raw mesh was sharper.

## What was tested, and what was not

Tested on the PC named above:

- All Direct3D-V3 numbers and images on this page, on ten models.
- The max-detail recipe as a workflow end to end from a fresh ComfyUI start (507 s for the whole job), in its earlier form without the texture stage.
- The UltraTex texture stage on four models (271 to 329 s each).
- The installer on a clean folder with `NoModels`: see `docs/installer_test.md`.

Not tested:

- **The model downloads of this installer** (my PC already had every model).
- **The workflow files** as they are: not opened in ComfyUI and not run yet. Their parts ran in the workflows they were built from.
- Any other GPU; real 6, 8 or 12 GB cards; a PC with 32 GB RAM or less; Windows 10; a first-time Hugging Face login.
- WTiVo on a card older than the RTX 50 series.
- The Linux script.
- The max-detail recipe on more than one character.

## Licences

- **This repository** (installer, my workflows, images): MIT, see `LICENSE`.
- **Direct3D-V3** code and weights (DreamTechAI) and the INT8 weights and nodes (Mstafa-awad): MIT.
- **DINOv3 ViT-H+** (Meta): DINOv3 License, gated. Not included; you download it with your own account.
- **UltraTex** (Yibo Zhang et al.) and the ComfyUI-UltraTex nodes (visualbruno): MIT for the node code; see the UltraTex project for its weights.
- **FLUX.2 klein base 9B** (Black Forest Labs): **FLUX Non-Commercial License**, gated. Not included. Read the licence yourself before you use the model or its results for paid work.
- **WTiVo** (Mstafa-awad): GPL-3.0-or-later.
- Workflows 1 to 5 include MostAadTech's support note; please keep it if you share them.

No model weights are in this repository. Every file is downloaded from its original publisher.

## Undo

1. Close ComfyUI.
2. In `ComfyUI\custom_nodes`, delete `ComfyUI-Direct3D-V3` (this also removes its environment and models), `ComfyUI-UltraTex` and `WTiVo-WatertightVoxel-ComfyuiNode`.
3. The installer lists the packages it added to ComfyUI's Python; remove them with `python_embeded\python.exe -m pip uninstall NAME` if nothing else needs them.
4. Optional: delete the UltraTex models in `ComfyUI\models` and the workflows it added.

## Credits

Direct3D-V3 by [DreamTechAI](https://github.com/DreamTechAI/Direct3D-V3). ComfyUI nodes, acceleration, INT8 weights, multiview and WTiVo by [MostAadTech](https://github.com/Mstafa-awad). UltraTex by Yibo Zhang et al.; ComfyUI nodes by [visualbruno](https://github.com/visualbruno). TRELLIS.2 by Microsoft.
