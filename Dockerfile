# Use the official CUDA-enabled image for compatibility with GStreamer
FROM nvidia/cuda:10.2-cudnn7-runtime-ubuntu18.04

# Set environment variables for GStreamer
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up the working directory
WORKDIR /app

# Copy the requirements file and install the necessary packages
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the application files
COPY app.py .

# Expose the port for the FastAPI app
EXPOSE 8000

# Run the FastAPI app with uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
