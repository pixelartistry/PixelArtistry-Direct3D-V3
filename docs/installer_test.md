# Installer test, 26 November 2026

What was run, and what it does and does not prove.

## Setup

- PC: Windows 11, RTX 5080 16 GB, 48 GB RAM, system Python 3.12.8.
- A clean test folder on another drive than the Windows temp folder, with an empty `ComfyUI\custom_nodes`,
  an empty `ComfyUI\models` and no workflows. Its `python_embeded` pointed to the Python of a working
  ComfyUI-Easy-Install (Python 3.12.10, PyTorch 2.8.0+cu128, ComfyUI 0.45.4).
- Command: `Install-Direct3D-V3-UltraTex.bat NoPause NoModels`, started from `Add-Ons\PixelArtistry-Direct3D-V3\`.

## Result

| Step | Result |
|---|---|
| Finds ComfyUI from the `Add-Ons` folder, checks GPU, Python 3.12, ComfyUI version, disk space | Passed |
| Saves the package list of ComfyUI's Python | Passed |
| Direct3D-V3 node pack: download, SHA-256 check, unpack | Passed, after a fix (see below) |
| Direct3D-V3 worker environment (`setup_windows.py --runtime-only`): PyTorch 2.8.0+cu128, Triton 3.8.0 | Passed |
| UltraTex and WTiVo node packs from GitHub at the pinned commits | Passed |
| Python packages for UltraTex and WTiVo | "Nothing missing": this Python already had them, so the install path for missing packages did not run |
| Model downloads | Skipped on purpose (`NoModels`) |
| Package list of ComfyUI's Python afterwards | Unchanged |
| Eight workflows copied (the set of 26 November, commit `d859f8a`) | Passed |
| A real Direct3D-V3 refinement with the fresh environment (worker started by hand, dwarf at 1024, models linked from the working install) | Passed: 31,858 tokens, 4.86 million triangles |

## The bug this test found

The first run stopped with "Could not move the node pack into custom_nodes". The installer unpacked into
the Windows temp folder and then moved the folder; Windows cannot move a folder to another drive that way.
It now unpacks into a temporary folder inside `ComfyUI` and moves from there.

## Not covered by this test

- Every model download (Direct3D-V3 INT8 weights, DINOv3, the UltraTex models, FLUX.2 klein base 9B).
- Installing missing Python packages into ComfyUI's Python, and the dry run that refuses version changes.
- The questions of the interactive mode (stage choice, licence prompts).
- Starting ComfyUI on the test folder: the fresh node packs were not loaded by a ComfyUI there. The same
  commits are installed in the working ComfyUI that produced the results in the README.
- Any other PC.
