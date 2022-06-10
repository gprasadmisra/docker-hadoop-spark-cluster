FROM ubuntu:20.04

USER root
EXPOSE 22/tcp
EXPOSE 22/udp

# install packages
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get install -y --no-install-recommends openssh-server \
  vim \
  wget \
  openjdk-11-jdk \
  python3 \
  python3-pip \
  python3-numpy \
  python3-matplotlib \
  python3-scipy \
  python3-pandas

# set environment vars
ENV PATH $PATH:$JAVA_HOME/bin
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

WORKDIR /tmp
RUN echo "PubkeyAuthentication yes" >> /etc/ssh/ssh_config && \
    echo "Host *" >> /etc/ssh/ssh_config

CMD service ssh start && sleep infinity
