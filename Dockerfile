FROM ubuntu:22.10
COPY . /dotfiles
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install --no-install-recommends tzdata \
    && apt-get install --no-install-recommends -y sudo bash git ansible \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENV RUNNING_INSIDE_DOCKER=1
ENV USER=root
CMD ["/dotfiles/scripts/install.sh"]
