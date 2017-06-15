FROM jenkins
# if we want to install via apt
USER root

# update source
# below config just work for china user.
RUN echo 'deb http://mirrors.163.com/debian/ jessie main non-free contrib' > /etc/apt/sources.list
RUN echo 'deb http://mirrors.163.com/debian/ jessie-updates main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.163.com/debian/ jessie-backports main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.163.com/debian/ jessie main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.163.com/debian/ jessie-updates main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.163.com/debian/ jessie-backports main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.163.com/debian-security/ jessie/updates main non-free contrib' >> /etc/apt/sources.list

# lib32stdc++6 lib32z1 lib32z1-dev thest package it need for android ndk build.
RUN apt-get update && apt-get install -y cppcheck file make ccache lib32stdc++6 lib32z1 lib32z1-dev && rm -rf /var/lib/apt/lists/*

# install android sdk
RUN mkdir -p /opt/android/android-sdk-linux && cd /opt/android/android-sdk-linux &&  wget -q https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
RUN cd /opt/android/android-sdk-linux && ls -la && unzip tools_r25.2.3-linux.zip 

RUN mkdir -p "/opt/android/android-sdk-linux/licenses"
RUN echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "/opt/android/android-sdk-linux/licenses/android-sdk-license"
RUN echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "/opt/android/android-sdk-linux/licenses/android-sdk-preview-license"
RUN (while sleep 3; do echo "y"; done) | /opt/android/android-sdk-linux/tools/android update sdk -u --filter platform-tools,android-25
RUN chmod -R 755 /opt/android/android-sdk-linux

# install android ndk
ENV ANDROID_NDK_HOME /opt/android/android-ndk
ENV ANDROID_NDK_VERSION r14b
# download
RUN mkdir /opt/android/android-ndk-tmp && cd /opt/android/android-ndk-tmp 
RUN wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
# uncompress
RUN unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# move to its final location
    mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
# remove temp dir
    cd ${ANDROID_NDK_HOME} && \
    rm -rf /opt/android/android-ndk-tmp

# install gradle 
RUN mkdir -p /opt/gradle && cd /opt/gradle && wget https://services.gradle.org/distributions/gradle-3.4.1-all.zip
RUN cd /opt/gradle && ls -al && unzip gradle-3.4.1-all.zip

# Change default timezone to Shanghai.  Different country change Shanghai to "ls /usr/share/zoneinfo/Asia/" command result
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

USER jenkins 

ENV GRADLE_HOME="/opt/gradle/gradle-3.4.1"
ENV ANDROID_NDK_ROOT="/opt/android/android-ndk"
ENV ANDROID_HOME="/opt/android/android-sdk-linux"
ENV ANDROID_NDK="${ANDROID_NDK_ROOT}"
ENV NDK_ROOT="${ANDROID_NDK}"
ENV PATH="${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${GRADLE_HOME}/bin:${CPP_LINT}:${ANDROID_NDK_ROOT}:${PATH}"
