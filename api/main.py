
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware

import librosa
import numpy as np
import uuid
import os
from moviepy import VideoFileClip

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "uploads"
CLIP_DIR = "clips"

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(CLIP_DIR, exist_ok=True)

def detect_energy_peaks(audio_path: str, threshold_percentile: int = 95):
    y, sr = librosa.load(audio_path)
    frame_length = 2048
    hop_length = 512
    rms = librosa.feature.rms(y=y, frame_length=frame_length, hop_length=hop_length)[0]
    threshold = np.percentile(rms, threshold_percentile)
    peaks = np.where(rms > threshold)[0]
    times = librosa.frames_to_time(peaks, sr=sr, hop_length=hop_length)
    return times

@app.post("/upload")
async def upload_video(file: UploadFile = File(...)):
    print(f"Recebido arquivo: {file.filename}, tipo: {file.content_type}")
    input_path = os.path.join(UPLOAD_DIR, file.filename)
    with open(input_path, "wb") as f:
        f.write(await file.read())

    audio_temp_path = input_path.replace(".mp4", "_audio.wav")
    video = VideoFileClip(input_path)
    if video.audio is None:
        return {"error": "O vídeo enviado não contém áudio."}
    video.audio.write_audiofile(audio_temp_path)

    peaks_seconds = detect_energy_peaks(audio_temp_path)
    if len(peaks_seconds) == 0:
        return {"error": "Nenhum pico detectado"}

    first_peak = peaks_seconds[0]
    start = max(0, first_peak - 5)
    end = min(video.duration, first_peak + 5)

    clip = video.subclipped(start, end)
    clip_filename = f"clip-{uuid.uuid4().hex}.mp4"
    clip_path = os.path.join(CLIP_DIR, clip_filename)
    clip.write_videofile(clip_path)

    return {"clip": clip_filename}

@app.get("/clip/{filename}")
def get_clip(filename: str):
    return FileResponse(os.path.join(CLIP_DIR, filename))
