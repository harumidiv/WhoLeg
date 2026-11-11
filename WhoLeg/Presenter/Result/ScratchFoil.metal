//
//  ScratchFoil.metal
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/11/11.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

static float hash21(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

static float valueNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float a = hash21(i);
    float b = hash21(i + float2(1, 0));
    float c = hash21(i + float2(0, 1));
    float d = hash21(i + float2(1, 1));
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

/// 点pから線分abまでの距離
static float segmentDistance(float2 p, float2 a, float2 b) {
    float2 ab = b - a;
    float len2 = dot(ab, ab);
    if (len2 < 0.0001) {
        return distance(p, a);
    }
    float t = clamp(dot(p - a, ab) / len2, 0.0, 1.0);
    return distance(p, a + ab * t);
}

/// スクラッチの銀はくを描くシェーダー
/// - size: 銀はくの大きさ（pt）
/// - tilt: 端末の傾き（-1〜1）。光の反射の位置が動く
/// - radius: 指で削れる太さの半分（pt）
/// - fade: 削り終わったときに残りを消すための不透明度
/// - points: 指でなぞった点の座標 (x, y) の並び。x < 0 の点はなぞりの区切り
[[ stitchable ]] half4 scratchFoil(float2 position,
                                   half4 color,
                                   float2 size,
                                   float2 tilt,
                                   float radius,
                                   float fade,
                                   device const float *points,
                                   int count) {
    // 一番近いなぞり線までの距離を求める
    float minDistance = 1e6;
    float2 previous = float2(-1.0);
    for (int i = 0; i + 1 < count; i += 2) {
        float2 p = float2(points[i], points[i + 1]);
        if (p.x < 0.0) {
            previous = float2(-1.0);
            continue;
        }
        float d = previous.x < 0.0 ? distance(position, p) : segmentDistance(position, previous, p);
        minDistance = min(minDistance, d);
        previous = p;
    }

    // ふちをギザギザにして、本当に削ったような跡にする
    float edgeNoise = (valueNoise(position * 0.35) - 0.5) * radius * 0.7
        + (hash21(floor(position * 0.8)) - 0.5) * 2.5;
    float edgeDistance = minDistance + edgeNoise;
    float scratched = 1.0 - smoothstep(radius - 1.5, radius + 1.0, edgeDistance);
    // 削り跡のまわりは銀はくがめくれて少し暗くなる
    float rim = (1.0 - smoothstep(radius, radius + 5.0, edgeDistance)) * (1.0 - scratched);

    // 細かい粒と、ヘアライン状のすじで金属っぽくする
    float grain = hash21(floor(position * 1.5));
    float brushed = valueNoise(float2(position.x * 0.04, position.y * 1.2));
    float shade = 0.86 + grain * 0.08 + brushed * 0.08;

    // 傾きに合わせて動く光の帯
    float2 uv = position / max(size, float2(1.0));
    float bandPosition = dot(uv, normalize(float2(1.0, 0.45)));
    float bandCenter = 0.5 + tilt.x * 0.7 + tilt.y * 0.35;
    float specular = exp(-pow((bandPosition - bandCenter) * 4.0, 2.0)) * 0.28;

    // 傾けるとキラッと光る小さな粒
    float cellSize = 3.0;
    float2 sparkleCell = floor(position / cellSize);
    float sparkleSeed = hash21(sparkleCell);
    float sparkle = 0.0;
    if (sparkleSeed > 0.9) {
        float2 jitter = float2(hash21(sparkleCell + 7.1), hash21(sparkleCell + 3.7)) * 0.5 + 0.25;
        float dotDistance = length(fract(position / cellSize) - jitter);
        float dotShape = 1.0 - smoothstep(0.0, 0.3, dotDistance);
        float phase = sin((tilt.x * 9.0 + tilt.y * 7.0) + sparkleSeed * 40.0);
        sparkle = dotShape * pow(max(phase, 0.0), 6.0) * 0.55;
    }

    float alpha = float(color.a);
    float3 rgb = float3(color.rgb) * shade + (specular + sparkle) * alpha - rim * 0.22 * alpha;
    float keep = (1.0 - scratched) * fade;
    rgb = clamp(rgb, 0.0, alpha) * keep;
    return half4(half3(rgb), half(alpha * keep));
}
