FROM debian:jessie
RUN apt-get update
RUN apt-get install -y wget

RUN mkdir /data
WORKDIR /data
COPY build.sh /

RUN /build.sh
