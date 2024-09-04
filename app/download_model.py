#!/usr/bin/env python3

import os

import ffmpeg
import numpy as np

from app.webservice import SAMPLE_RATE


ASR_ENGINE = os.getenv("ASR_ENGINE", "openai_whisper")
if ASR_ENGINE == "faster_whisper":
    from app.faster_whisper.core import transcribe
else:
    from app.openai_whisper.core import transcribe


def generate_audio(duration_s: int = 1, sr: int = SAMPLE_RATE) -> np.ndarray:
    out, _ = (
        ffmpeg.input(f"sine=frequency=1000:duration={duration_s}", format="lavfi")
        .output("-", format="s16le", acodec="pcm_s16le", ac=1, ar=sr)
        .run(cmd="ffmpeg", capture_stdout=True, capture_stderr=True)
    )
    return np.frombuffer(out, np.int16).flatten().astype(np.float32) / 32768.0


if __name__ == "__main__":
    transcribe(generate_audio(), "transcribe", "en", None, None, None, "txt")
    print("Successfully downloaded and loaded model")
