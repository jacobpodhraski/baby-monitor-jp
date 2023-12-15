ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update -y && \
    apt-get install -y \
        libgstreamer1.0-0 \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav \
        gstreamer1.0-doc \
        gstreamer1.0-tools \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        pkg-config \
        zlib1g-dev \
        libwebp-dev \
        libtbb2 \
        libtbb-dev \
        libgtk2.0-dev \
        pkg-config \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libv4l-dev \
        cmake \
        autoconf \
        autotools-dev \
        build-essential \
        gcc \
        git \
        python3 \
        python3-pip \
        python3-dev \
        python3-gi \
        python3-gst-1.0 \
        python3-numpy \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

ENV OPENCV_RELEASE_TAG 4.1.1

RUN git clone --depth 1 -b ${OPENCV_RELEASE_TAG}  https://github.com/opencv/opencv.git /var/local/git/opencv

RUN mkdir -p /var/local/git/opencv/build && \
    cd /var/local/git/opencv/build && \
    cmake -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D CMAKE_BUILD_TYPE=Release \
          -D WITH_GSTREAMER=ON \
          -D WITH_GSTREAMER_0_10=OFF \
          -D WITH_CUDA=OFF \
          -D WITH_TBB=ON \
          -D WITH_LIBV4L=ON \
          -D WITH_FFMPEG=ON \
          -D OPENCV_GENERATE_PKGCONFIG=ON \
          -D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages ..

RUN  cd /var/local/git/opencv/build && make install

ADD requirements.txt requirements.txt

RUN pip3 install --upgrade pip setuptools \
    && pip3 install -r requirements.txt

WORKDIR /app

# Run the FastAPI app with uvicorn
CMD ["python3", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
