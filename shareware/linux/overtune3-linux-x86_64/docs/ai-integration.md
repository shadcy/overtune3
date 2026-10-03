# DSP Chat and Analysis Artifacts

Overtune provides deterministic filter calculations to the chat model as versioned JSON. The model explains those results; it does not generate filter coefficients or response samples.

## Artifact API

`FilterEngine::analysisArtifactsJson(maxPoints)` returns the active design. `FilterEngine::analyzeVariantJson(order, response, maxPoints)` designs an alternate order/family while preserving the active topology, sample rate, cutoffs, ripple, and stopband attenuation. Accepted response keys are `butterworth`, `chebyshev_i`, `chebyshev_ii`, `elliptic`, and `bessel`. Both return a compact JSON object with schema identifier `overtune.filter-analysis.v1`.

The frequency grid is computed from the full DSP analysis, with logarithmic spacing and additional samples near specification edges and pole/zero features. The returned `frequencyResponse.points` is an index-preserving decimation of that source grid, not a newly interpolated response. `sourcePointCount` reports the full source size. `maxPoints` is clamped to 32-1024; the chat sends 384 active-design points and 320 comparison points.

## Fields and Units

- `specification`: response family, topology, order, sample rate and edge frequencies in Hz, passband ripple in dB, and stopband attenuation in dB.
- `transferFunction.gain`: scalar applied to the SOS cascade. Each `sos` row is `[b0, b1, b2, a0, a1, a2]` for one digital second-order section.
- `roots.poles` and `roots.zeros`: complete complex z-plane roots as `[real, imaginary]` pairs. Repeated roots remain repeated.
- `frequencyResponse.columns`: `frequencyHz`, `magnitudeDb`, `phaseDeg`, and `groupDelaySamples`, in that order for each point.
- `timeResponse.impulse` and `timeResponse.step`: `[sampleIndex, amplitude]` pairs for the calculated time-response window.
- `verification`: stability, reference-model, specification, and numerical error results produced by the native verifier. Error values are numerical diagnostics, not claims of zero floating-point error.

Non-finite values are serialized as JSON `null`; consumers must not treat them as zero. Phase and group delay are undefined at exact transfer-function zeros. Units are encoded in field names and in `frequencyResponse.columns` so clients need not infer them from labels.

## OpenRouter Chat

The app sends OpenAI-compatible chat completions to `https://openrouter.ai/api/v1/chat/completions`. The user supplies a model ID and API key. On Windows, the key is encrypted with DPAPI for the current user; other platforms keep it in memory only. Requests go directly from Overtune to OpenRouter.

The model may call `analyze_filter_variant` for quantitative comparisons. Each response is limited to three variant designs and two tool rounds. Plot-related questions can show the active design even when no variant tool call is needed. The UI plots magnitude, phase, group-delay, pole-zero, impulse, or step artifacts directly from the analysis results. Providers that reject tool parameters are retried without tools; in that mode the prompt prohibits fabricated comparison data.

Chat renders Markdown and converts common LaTeX notation to readable symbols and expressions. It is not a full TeX typesetting engine; unrecognized macros remain visible as source text.
