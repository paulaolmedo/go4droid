# Copyright 2017 The Perkeep Authors.

FROM openjdk:8u282-slim-buster

CMD ["./gradlew"]

# To enable running android tools such as aapt
RUN apt-get update && apt-get -y upgrade \
&& apt-get install -y lib32z1 lib32stdc++6 \
&& apt-get -y --no-install-recommends install curl wget gcc unzip \
&& apt-get -y --no-install-recommends install ca-certificates libc6-dev \
&& apt-get clean \
&& apt-get autoremove -y

VOLUME "/home/gopher/.gradle"
ENV GOPHER /home/gopher

# Get android sdk, ndk, and rest of the stuff needed to build the android app.
WORKDIR $GOPHER
RUN mkdir android-sdk
ENV ANDROID_HOME $GOPHER/android-sdk
WORKDIR $ANDROID_HOME
RUN curl -O https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
RUN echo '444e22ce8ca0f67353bda4b85175ed3731cae3ffa695ca18119cbacef1c1bea0  sdk-tools-linux-3859397.zip' | sha256sum -c
RUN unzip sdk-tools-linux-3859397.zip
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager --update
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'platforms;android-30'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'build-tools;30.0.0'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'extras;android;m2repository'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'ndk-bundle'

# Get gradle. We don't actually need to build the app, but we need it to
# generate the gradle wrapper, since it's not included in the app's repo.
# TODO sacar esto y agregar el wrapper cuando se compile la app
WORKDIR $GOPHER
ENV GRADLE_VERSION 6.8.3
ARG GRADLE_DOWNLOAD_SHA256=7faa7198769f872826c8ef4f1450f839ec27f0b4d5d1e51bade63667cbccd205
RUN set -o errexit -o nounset \
	&& echo "Downloading Gradle" \
	&& wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
RUN echo "Checking download hash" \
	&& echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check -
RUN echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip
RUN mkdir $GOPHER/bin \
	&& ln --symbolic "${GOPHER}/gradle-${GRADLE_VERSION}/bin/gradle" $GOPHER/bin/gradle

# Get Go stable release
WORKDIR $GOPHER
RUN curl -O https://dl.google.com/go/go1.16.2.linux-amd64.tar.gz --output go1.16.2.linux-amd64.tar.gz
RUN tar -xzf go1.16.2.linux-amd64.tar.gz
ENV GOPATH $GOPHER
ENV GOROOT $GOPHER/go
ENV PATH $PATH:$GOROOT/bin:$GOPHER/bin

# Configure env to work with modules
ENV GO111MODULE=auto

#RUN go get -u golang.org/x/mobile/cmd/gomobile
#RUN go get -u golang.org/x/mobile/cmd/gobind
