from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
import cv2
from typing import Generator
import os
import time

app = FastAPI()

pipeline = (
    "nvarguscamerasrc ! "
    "video/x-raw(memory:NVMM), width=768, height=432, format=NV12 ! "
    "nvvidconv ! "
    "video/x-raw, format=BGRx ! "
    "videoconvert ! "
    "video/x-raw, format=BGR ! "
    "appsink"
)

print("GStreamer Pipeline:", pipeline)

# Create GStreamer pipeline
camera = cv2.VideoCapture(pipeline, cv2.CAP_GSTREAMER)

# Check if the camera opened successfully
if not camera.isOpened():
    raise HTTPException(status_code=500, detail="Error: Could not open camera.")

def generate_frames() -> Generator[bytes, None, None]:
    while True:
        success, frame = camera.read()
        if not success:
            break
        else:
            ret, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.get("/live_stream")
async def video_feed():
    return StreamingResponse(generate_frames(), media_type="multipart/x-mixed-replace; boundary=frame")
