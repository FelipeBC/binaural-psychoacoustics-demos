# Source audio (not included)

The source files for the radio drama are not redistributed:

| File(s) | Content | Origin |
|---|---|---|
| `L.wav`, `R.wav`, `C.wav`, `Ls.wav`, `Rs.wav` | Room tone (5 static beds) | Soundly SFX library |
| `Door.wav`, `Footsteps.wav`, `Footsteps2.wav`, `Radio.wav` | Foley / effects | Soundly SFX library |
| `Dx1.wav`, `Dx2.wav` | Character dialogue | ElevenLabs text-to-speech |
| `Dx3.wav`, `Dx4.wav` | Overhead voice | Recorded by the author in an anechoic chamber |
| `Music.wav` | Music on the radio | "The Girl from Ipanema" (Stan Getz & João Gilberto) |

The finished binaural mix is in [`../render/BinauralRadioDrama.wav`](../render/BinauralRadioDrama.wav).

**To re-render**, add WAV files with exactly these names that are **mono, 44.1 kHz and exactly 30 s long (1,323,000 samples)**, aligned to the drama's timeline: `Main.m` uses absolute times (e.g. the door between 1 and 3 s) and adds the rendered stems sample by sample, so shorter, longer or stereo files will fail or be misplaced.
