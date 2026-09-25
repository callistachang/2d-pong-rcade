#!/usr/bin/env python3
"""Generate the game's retro square-wave SFX into assets/. Run from repo root."""

import wave
import struct
import math

def make_tone(filename, freqs_durations, sample_rate=44100, volume=0.3):
    frames = []
    for freq, duration in freqs_durations:
        n_samples = int(sample_rate * duration)
        fade_samples = max(1, int(sample_rate * 0.005))
        for i in range(n_samples):
            t = i / sample_rate
            value = 1.0 if math.sin(2 * math.pi * freq * t) >= 0 else -1.0
            if i < fade_samples:
                value *= i / fade_samples
            elif i > n_samples - fade_samples:
                value *= (n_samples - i) / fade_samples
            sample = int(value * volume * 32767)
            frames.append(struct.pack('<h', sample))
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        f.writeframes(b''.join(frames))

if __name__ == "__main__":
    make_tone('assets/paddle_hit.wav', [(440, 0.05)])
    make_tone('assets/wall_bounce.wav', [(220, 0.05)])
    make_tone('assets/score.wav', [(300, 0.15), (150, 0.15)])
    print("done")
