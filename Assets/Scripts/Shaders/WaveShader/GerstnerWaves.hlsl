#ifndef GERSTNER_WAVES
#define GERSTNER_WAVES

#ifndef UNITY_PI
    #define UNITY_PI 3.14159265358979323846
#endif

// Accumulates a Gerstner wave into the running tangent/bitangent and returns its displacement.
// wave.xy : direction (x,z)
// wave.z  : steepness s in [0..1]
inline float3 AccumulateWave(
    float4 wave,                  // (dirX, dirZ, steepness, wavelength)
    float3 positionOS,            // object-space position
    float  time,                  // (seconds)
    float  gravity,               // 9.81
    inout float3 tangentOS,       
    inout float3 bitangentOS      
) {
    const float2 waveDirXZ = normalize(wave.xy);
    const float  k = 2.0 * UNITY_PI / max(wave.w, 1e-4); // wave number
    const float  c = sqrt(gravity / k); // phase speed
    const float  f = k * (dot(waveDirXZ, positionOS.xz) - c * time); // phase
    const float  steepness = saturate(wave.z); // clamped [0..1]
    const float  amplitude = steepness / k;
    const float  cosf = cos(f);
    const float  sinf = sin(f);

    // Displacement in object space
    float3 displacementOS;
    displacementOS.x = waveDirXZ.x * (amplitude * cosf);
    displacementOS.y = amplitude * sinf;
    displacementOS.z = waveDirXZ.y * (amplitude * cosf);

    // Accumulate partial derivatives
    tangentOS   += float3(-waveDirXZ.x * waveDirXZ.x * (steepness * sinf),
                           waveDirXZ.x * (steepness * cosf),
                          -waveDirXZ.x * waveDirXZ.y * (steepness * sinf));

    bitangentOS += float3(-waveDirXZ.x * waveDirXZ.y * (steepness * sinf),
                           waveDirXZ.y * (steepness * cosf),
                          -waveDirXZ.y * waveDirXZ.y * (steepness * sinf));

    return displacementOS;
}

// Shader Graph entry point: sums three Gerstner waves and outputs displacement & normal in object space.
inline void GerstnerWaves_float(
    float4 WaveA,
    float4 WaveB,
    float4 WaveC,
    float  TimeValue,
    float3 PositionOS,
    float  Gravity,
    out float3 OffsetOS,
    out float3 NormalOS
) {
    float3 tangentOS   = float3(1.0, 0.0, 0.0);
    float3 bitangentOS = float3(0.0, 0.0, 1.0);

    float3 totalOffsetOS = float3(0.0, 0.0, 0.0);
    totalOffsetOS += AccumulateWave(WaveA, PositionOS, TimeValue, Gravity, tangentOS, bitangentOS);
    totalOffsetOS += AccumulateWave(WaveB, PositionOS, TimeValue, Gravity, tangentOS, bitangentOS);
    totalOffsetOS += AccumulateWave(WaveC, PositionOS, TimeValue, Gravity, tangentOS, bitangentOS);

    OffsetOS = totalOffsetOS;
    NormalOS = normalize(cross(bitangentOS, tangentOS));
}

#endif // GERSTNER_WAVES
