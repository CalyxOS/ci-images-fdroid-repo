FROM debian:bookworm

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN echo Etc/UTC > /etc/timezone \
	&& echo 'APT::Install-Recommends "0";' \
		'APT::Install-Suggests "0";' \
		'APT::Acquire::Retries "20";' \
		'APT::Get::Assume-Yes "true";' \
		'Dpkg::Use-Pty "0";' \
		'quiet "1";' \
        >> /etc/apt/apt.conf.d/99gitlab

RUN apt-get update \
	&& apt-get upgrade \
	&& apt-get dist-upgrade \
	&& apt-get install \
		apksigner \
		git \
		lzip \
		openjdk-17-jdk-headless \
		python3 python3-pip \
		rsync \
		wget \
	&& pip install --break-system-packages \
		git+https://github.com/androguard/androguard@16a6bd21946bfe3d75639ffd3d96957971b6553f \
		git+https://gitlab.com/fdroid/fdroidserver@2.3a2

# Debian has apksigner depend on binfmt support which isn't very docker friendly
# We create a shell wrapper instead
RUN printf '#!/bin/sh\njava -jar /usr/lib/android-sdk/build-tools/debian/apksigner.jar "$@"' > /usr/local/bin/apksigner \
	&& chmod +x /usr/local/bin/apksigner

COPY test /
