/*
 * Velo-Lite Shader v1.0.0b — depth-of-field pass helper
 * Copyright (C) 2026 Super Gug
 * SPDX-License-Identifier: LGPL-3.0-only
 * Derived from E-LITE shaders / MakeUp - Ultra Fast; see root notices and licenses.
 * Uses only the scene color/depth channel; water shading remains in upstream files.
 */
#define VELO_DOF_BACKGROUND_ONLY
vec3 velo_dof_blur(vec4 centerColorDepth, sampler2D colorDepthImage, vec2 uv, float strength, float noise) {
    vec3 centerColor = centerColorDepth.rgb;
    float sceneDepth = centerColorDepth.a;
    float depthDelta = max(sceneDepth - centerDepthSmooth, 0.0);
    float blurRadius = 0.0;
    if (sceneDepth > 0.56) { // Preserve first-person hands as in upstream.
        blurRadius = max(depthDelta - 0.000075, 0.0) * fov_y_inv;
        blurRadius = blurRadius * inversesqrt(0.1 + blurRadius * blurRadius) * strength;
        blurRadius = min(blurRadius, 0.1);
    }
    if (blurRadius <= min(pixelSizeX, pixelSizeY)) return centerColor;
    vec2 blurVector = vec2(blurRadius * inv_aspect_ratio, blurRadius);
    float radiusPixels = blurRadius * viewHeight;
    float lod = max(log2(max(radiusPixels, 1.0)) - 1.0, 0.0);
    float phase = noise * 6.2831853;
    vec3 sumColor = vec3(0.0);
    float sumWeight = 0.0;
    const int sampleCount = 4;
    for (int i = 0; i < sampleCount; ++i) {
        float fi = float(i);
        float sampleRadius = sqrt((fi + noise) / float(sampleCount));
        float angle = fi * 2.3999632 + phase;
        vec2 offset = vec2(cos(angle), sin(angle)) * blurVector * sampleRadius;
        vec2 sampleUv = uv + offset;
        vec4 sampleColorDepth = texture2DLod(colorDepthImage, sampleUv, lod);
        float sampleDepth = texture2DLod(colorDepthImage, sampleUv, 0.0).a;
        if (sampleDepth + 0.000075 < centerDepthSmooth) continue;
        float weight = exp(-2.5 * sampleRadius * sampleRadius);
        sumColor += sampleColorDepth.rgb * weight;
        sumWeight += weight;
    }
    return sumWeight > 1e-5 ? sumColor / sumWeight : centerColor;
}
