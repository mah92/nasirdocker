# Minimal docker container to build android qt5.12 projects

FROM ubuntu:22.04
MAINTAINER Rabit <home@rabits.org> (@rabits)
ARG QT_VERSION=5.12.10
ARG NDK_VERSION=r21
ARG SDK_PLATFORM=android-29
ARG SDK_BUILD_TOOLS=28.0.3
ARG SDK_PACKAGES="tools platform-tools"

ENV DEBIAN_FRONTEND noninteractive

# Addresses
ENV QT_PATH /opt/Qt
ENV QT_ANDROID_BASE ${QT_PATH}/${QT_VERSION}
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_SDK_ROOT ${ANDROID_HOME}
ENV ANDROID_NDK_ROOT /opt/android-ndk
ENV OPENCV_ANDROID_SDK_ROOT /opt/opencv-android-sdk

ENV ANDROID_NDK_HOST linux-x86_64
ENV ANDROID_NDK_PLATFORM android-29
ENV QMAKESPEC android-clang
ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

# Install updates & requirements:
#  * git, openssh-client, ca-certificates - clone & build
#  * locales, sudo - useful to set utf-8 locale & sudo usage
#  * curl - to download Qt bundle
#  * make, default-jdk, ant - basic build requirements
#  * libsm6, libice6, libxext6, libxrender1, libfontconfig1, libdbus-1-3 - dependencies of Qt bundle run-file
#  * libc6:i386, libncurses5:i386, libstdc++6:i386, libz1:i386 - dependencides of android sdk binaries

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends \
    git \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
    make \
    openjdk-8-jdk \
    ant \
    libarchive-tools \
    p7zip-full \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libfontconfig1 \
    libdbus-1-3 \
    xz-utils \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    libz1:i386
RUN apt-get clean

RUN apt-get install -y --no-install-recommends \
    bzip2 \
    unzip \
    gcc \
    g++ \
    cmake \
    patch \
    python3 \
    rsync \
    flex \
    bison

# Download & unpack android SDK
# ENV JAVA_OPTS="-XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee"
RUN apt-get remove -y openjdk-11-jre-headless
RUN curl -Lo /tmp/sdk-tools.zip 'https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip' \
    && mkdir -p ${ANDROID_HOME} \
    && unzip /tmp/sdk-tools.zip -d ${ANDROID_HOME} \
    && rm -f /tmp/sdk-tools.zip \
    && yes | sdkmanager --licenses && sdkmanager --verbose "platforms;${SDK_PLATFORM}" "build-tools;${SDK_BUILD_TOOLS}" ${SDK_PACKAGES}

# Download and cache gradle 
RUN mkdir /tmp/android \
    && curl -Lo /tmp/android/gradle.zip "https://services.gradle.org/distributions/gradle-4.6-bin.zip" \
    && unzip /tmp/android/gradle.zip -d /opt/gradle  \
    && rm -rf /tmp/android
#RUN apt-get install -y --no-install-recommends gradle
ENV PATH /opt/gradle/gradle-4.6/bin:${PATH}

COPY minimal-android-project /opt/minimal-android-project
RUN cd /opt/minimal-android-project/ \
    && gradle wrapper --distribution-type all
# && ./gradlew

# Download & unpack android NDK & remove any platform which is not 
RUN mkdir /tmp/android \
    && curl -Lo /tmp/android/ndk.zip "https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-x86_64.zip" \
    && unzip /tmp/android/ndk.zip -d /tmp \
    && mv /tmp/android-ndk-${NDK_VERSION} ${ANDROID_NDK_ROOT} \
    && cd / \
    && rm -rf /tmp/android \
    && find ${ANDROID_NDK_ROOT}/platforms/* -maxdepth 0 ! -name "$ANDROID_NDK_PLATFORM" -type d -exec rm -r {} +

# Download OpenCV SDK
RUN curl -Lo /tmp/opencv-android-sdk.zip 'https://github.com/opencv/opencv/releases/download/4.7.0/opencv-4.7.0-android-sdk.zip' \
    && mkdir -p ${OPENCV_ANDROID_SDK_ROOT} \
    && unzip /tmp/opencv-android-sdk.zip -d ${OPENCV_ANDROID_SDK_ROOT} \
    && rm -f /tmp/opencv-android-sdk.zip

# QT
COPY extract-qt-installer.sh /tmp/qt/
COPY install-qt.sh /tmp/qt/

RUN for tc in \
        "android_armv7" \
        "android_arm64_v8a" \
        ; do /tmp/qt/install-qt.sh --version ${QT_VERSION} --target android --directory "${QT_PATH}" --toolchain $tc \
      qtbase \
      qtsensors \
      qtquickcontrols2 \
      qtquickcontrols \
      qtmultimedia \
      qtlocation \
      qtimageformats \
      qtgraphicaleffects \
      qtdeclarative \
      qtandroidextras \
      qttools \
      qtimageformats \
      qtsvg \
      ; done

# cppcheck and related stuff
RUN apt-get install -y --no-install-recommends \
    cppcheck pip 
RUN pip install cppcheck-codequality

# Just for tests
#RUN apt install -y --no-install-recommends build-essential

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# gitlab-runner
##RUN apt-get install -y --no-install-recommends gitlab-runner
RUN curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"
RUN chmod +x /usr/local/bin/gitlab-runner
RUN useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
RUN gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
RUN gitlab-runner register \
  --non-interactive \
  --url "https://hamgit.ir/" \
  --registration-token "GR1348941kqbDiym8dnKHz83hmxf-" \
  --executor "shell" \
  --shell "bash" \
  --description "android-deploy-runneru" \
  --locked="false"
  
# Eigen 3.3.3
RUN cd /opt && git clone -b 3.3.3 https://gitlab.com/libeigen/eigen.git --recursive
ENV PATH_TO_EIGEN_SOURCE /opt/eigen

RUN cd $PATH_TO_EIGEN_SOURCE && mkdir build-armeabi-v7a && cd build-armeabi-v7a \
&& cmake \
    -DBUILD_TESTING=OFF \
    -DCMAKE_ANDROID_API=$SDK_PLATFORM \
    -DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a \
    -DCMAKE_ANDROID_STL_TYPE=c++_shared \
    -DCMAKE_Fortran_COMPILER= \
    -DCMAKE_SYSTEM_NAME=Android \
    -DEIGEN_BUILD_DOC=OFF
    ..
RUN cmake --build . \
          --config Release

RUN cd $PATH_TO_EIGEN_SOURCE && mkdir build-arm64-v8a && cd build-arm64-v8a \
&& cmake \
    -DBUILD_TESTING=OFF \
    -DCMAKE_ANDROID_API=$SDK_PLATFORM \
    -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
    -DCMAKE_ANDROID_STL_TYPE=c++_shared \
    -DCMAKE_Fortran_COMPILER= \
    -DCMAKE_SYSTEM_NAME=Android \
    -DEIGEN_BUILD_DOC=OFF
    ..
RUN cmake --build . \
          --config Release

# Compile ceressolver
RUN cd /opt && git clone -b 2.1.0 https://ceres-solver.googlesource.com/ceres-solver --recursive
ENV PATH_TO_CERES_SOURCE /opt/ceres-solver

RUN cd $PATH_TO_CERES_SOURCE && mkdir build-armeabi-v7a && cd build-armeabi-v7a \
    && cmake \
        -DCMAKE_TOOLCHAIN_FILE= $ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake \
        -DEigen3_DIR=$PATH_TO_EIGEN_SOURCE/build-armeabi-v7a \
        -DANDROID_ABI=armeabi-v7a \
        -DANDROID_STL=c++_shared \
        -DANDROID_NATIVE_API_LEVEL=$SDK_PLATFORM \
        -DBUILD_SHARED_LIBS=ON \
        -DMINIGLOG=ON \
        .. \
    && cmake --build .
    
RUN cd $PATH_TO_CERES_SOURCE && mkdir build-arm64-v8a && cd build \
    && cmake \
        -DCMAKE_TOOLCHAIN_FILE= $ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake \
        -DEigen3_DIR=$PATH_TO_EIGEN_SOURCE/build-arm64-v8a \
        -DANDROID_ABI=arm64-v8a \
        -DANDROID_STL=c++_shared \
        -DANDROID_NATIVE_API_LEVEL=$SDK_PLATFORM \
        -DBUILD_SHARED_LIBS=ON \
        -DMINIGLOG=ON \
        $PATH_TO_CERES_SOURCE \
    && cmake --build .

CMD ["/bin/sh","-c","sudo gitlab-runner start; sudo gitlab-runner verify; while true; do echo Alhamdolellah; sleep 5;done"]
