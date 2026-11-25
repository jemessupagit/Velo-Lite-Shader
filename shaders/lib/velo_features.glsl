/* Velo-Lite visual polish — deterministic per-pixel math, no new texture reads/loops.
 * Copyright (C) 2026 Super Gug — SPDX-License-Identifier: LGPL-3.0-only
 */
float velo_luma(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}
vec3 velo_visual_polish(vec3 color, vec2 uv) {
    float y = velo_luma(color);

    // 1) Subtle cool shadows / warm highlights (split-toning).
    float shadowMask = 1.0 - smoothstep(0.04, 0.48, y);
    float highlightMask = smoothstep(0.42, 0.96, y);
    color *= vec3(1.0 - 0.010 * shadowMask + 0.012 * highlightMask,
                  1.0 + 0.004 * shadowMask + 0.006 * highlightMask,
                  1.0 + 0.020 * shadowMask - 0.015 * highlightMask);

    // 2) Gentle filmic shoulder: preserve bright detail without a hard clip.
    vec3 excess = max(color - vec3(0.82), vec3(0.0));
    color -= excess * excess * 0.045;

    // 3) Mild luminance-aware color separation for a richer, not globally saturated, look.
    y = velo_luma(color);
    float chroma = max(max(color.r, color.g), color.b) - min(min(color.r, color.g), color.b);
    float vibrance = (1.0 - clamp(chroma, 0.0, 1.0)) * 0.035;
    color = mix(vec3(y), color, 1.0 + vibrance);

    // 4) Very subtle highlight bloom approximation; arithmetic only, not a blur pass.
    float glow = smoothstep(0.72, 1.35, velo_luma(color));
    color += color * (glow * 0.018);

    // 5) Soft cinematic vignette, calculated from screen coordinates only.
    vec2 centered = (uv - vec2(0.5)) * vec2(1.0, 1.0);
    float radial = dot(centered, centered);
    float vignette = 1.0 - 0.075 * smoothstep(0.12, 0.50, radial);
    color *= vignette;

    // 6) Tiny midtone contrast lift, with neutral pivot to avoid shifting black point.
    color = (color - vec3(0.5)) * 1.012 + vec3(0.5);
    return max(color, vec3(0.0));
}
float velo_output_dither(vec2 pixelPosition) {
    vec2 p = floor(pixelPosition);
    return fract(dot(p, vec2(0.75487766624669276, 0.569840290998))) - 0.5;
}
