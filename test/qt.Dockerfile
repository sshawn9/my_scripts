FROM sshawn/bionic_remote_env:1.0
# RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g'  /etc/apt/sources.list
# RUN sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g'  /etc/apt/sources.list
# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-dev \
    mesa-common-dev \
    libglu1-mesa-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libxcb-glx0-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libdbus-1-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libxcb-glx0-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libdbus-1-dev \
    wget \
    tar \
    bzip2 \
    xz-utils

# Download and extract Qt
RUN wget -O qt.tar.xz "https://download.qt.io/official_releases/qt/5.15/5.15.1/single/qt-everywhere-src-5.15.1.tar.xz" \
 && tar -xf qt.tar.xz \
 && rm qt.tar.xz

# Build and install Qt
RUN cd qt-everywhere-src-5.15.1 \
 && ./configure -opensource -confirm-license -no-opengl \
 && make -j$(nproc) \
 && make install

# Clean up
RUN rm -r qt-everywhere-src-5.15.1
