FROM fedora:37
COPY . /dotfiles
RUN dnf upgrade -y \
    && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC dnf install -y tzdata \
    && dnf install -y sudo bash git ansible \
    && dnf clean -y all
ENV RUNNING_INSIDE_DOCKER=1
ENV USER=root
CMD ["/dotfiles/scripts/install.sh"]
