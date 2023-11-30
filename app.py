from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
import cv2
from typing import Generator
import os

os.environ["DISPLAY"] = ":0"
os.environ["NV_TEGRA_CAMERA_PROTOCOL"] = "0"

app = FastAPI()

# GStreamer pipeline string for camera capture
pipeline = "nvarguscamerasrc ! video/x-raw(memory:NVMM), width=(int)1920, height=(int)1080, format=(string)NV12, framerate=(fraction)30/1 ! nvvidconv flip-method=0 ! video/x-raw, format=(string)BGRx ! videoconvert ! video/x-raw, format=(string)BGR ! appsink"
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

@app.get("/")
async def video_feed():
    return StreamingResponse(generate_frames(), media_type="multipart/x-mixed-replace; boundary=frame")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

