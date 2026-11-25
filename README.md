# Velo-Lite Shader v1.0.0b (beta)

Velo-Lite is an E-LITE shaders 5.1.5 derivative based on MakeUp - Ultra Fast. The original E-LITE configuration, shader menus, language strings, and defaults are preserved without added Velo settings. Code-only changes include stable soft-shadow sampling, a separate background-oriented DoF helper, TAA zero guards, a safer gamma input, use of the existing FXAA toggle on the ordinary output path, and a low-cost visual-polish suite: split-toning, a soft highlight shoulder, restrained luminance-aware vibrance, a highlight glow approximation, a subtle vignette, a slight midtone contrast lift, and deterministic output dithering. These use arithmetic only—no additional texture fetches or loops.

The DoF helper is only used when the existing E-LITE `DOF` option is enabled. It does not read or modify water shader files. DoF can still blur water if it lies outside the focus plane, because there is no new water mask. All original E-LITE/MakeUp files, textures and credits are retained.

## Installation

Put this ZIP directly into the `shaderpacks` folder of the Minecraft instance. Its archive root contains `shaders/` directly. Start Minecraft with Iris or OptiFine and select the pack in **Options → Video Settings → Shader Packs**. The ZIP structure and archive CRC were checked; in-game rendering still needs to be tested on the target setup.

## License and attribution

See [`VELO-LITE-NOTICE.md`](VELO-LITE-NOTICE.md), [`Velo-Lite-LICENSE`](Velo-Lite-LICENSE), and the retained upstream `LICENSE` and credits. Velo-Lite does not claim authorship of E-LITE or MakeUp.


## Velo sunrays

The existing lightweight screen-space godray path is enabled in low, medium, high, and max presets (not in no-effects/very-low). Sunrays are added as a colored light contribution instead of replacing the scene color. This uses the existing depth-sampling loop; cost is limited to the pack’s existing small sample count, so it is light compared with shadow-map volumetrics but is not literally free.
