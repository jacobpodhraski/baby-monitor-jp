#!/bin/bash

ARCH=$(uname -m)
if [ -n "$1" ] && [ "$1" == "aarch64" ]; then
  ARCH=$1
fi

if [ "${ARCH}" == "aarch64" ]; then
    BASE_IMAGE="nvcr.io/nvidia/l4t-base:r32.5.0"
else
    BASE_IMAGE="ubuntu:18.04"
fi

docker build --build-arg BASE_IMAGE=${BASE_IMAGE} -t video-stream-api .

