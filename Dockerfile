# Base image
FROM alpine:3.18.4
LABEL name=intense-security/k8s-audit-utils
LABEL maintainer="Intense Security"
LABEL version="1.1.1"


ARG USERNAME=pentester
RUN addgroup -S $USERNAME && adduser -S $USERNAME -G $USERNAME

# Moving to temp for downloads and installations.
WORKDIR /tmp

# gcompat for Goland errors when installing kubeaudit and others.
RUN apk update && apk add --no-cache bash wget git python3 curl gcompat sudo jq yq

# may the user need root sometimes
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME

# python3 as def
RUN ln -sf /usr/bin/python3 /usr/bin/python

# kubectl and alias
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl && cp kubectl /usr/bin


# kubeaudit
RUN wget "https://github.com/Shopify/kubeaudit/releases/download/v0.22.0/kubeaudit_0.22.0_linux_amd64.tar.gz"
RUN tar -xzf kubeaudit_0.22.0_linux_amd64.tar.gz
RUN chmod +x ./kubeaudit && cp kubeaudit /usr/bin/
RUN rm ./kubeaudit ./kubectl ./kubeaudit_0.22.0_linux_amd64.tar.gz
# fix go binaries execution (kubeaudit will fail if this line is not executed)
# https://stackoverflow.com/a/35613430
#RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# Kubescape
RUN curl -s https://raw.githubusercontent.com/kubescape/kubescape/master/install.sh | /bin/bash


# POPEYE
RUN wget "https://github.com/derailed/popeye/releases/download/v0.11.1/popeye_Linux_x86_64.tar.gz"
RUN tar -xzf popeye_Linux_x86_64.tar.gz
RUN mv popeye /usr/bin/

# Trivy
RUN wget "https://github.com/aquasecurity/trivy/releases/download/v0.33.0/trivy_0.33.0_Linux-64bit.tar.gz"
RUN tar -xzf trivy_0.33.0_Linux-64bit.tar.gz
RUN mv trivy /usr/bin/
RUN rm /tmp/*
# update trivy's db for the first time: ghcr.io/aquasecurity/trivy-db
RUN ./trivy filesystem /opt/stuff/

# Peirates
RUN wget https://github.com/inguardians/peirates/releases/download/v1.1.13/peirates-linux-amd64.tar.xz
RUN xzcat peirates-linux-amd64.tar.xz > peirates-linux-amd64.tar
RUN tar -xf peirates-linux-amd64.tar
RUN mv /tmp/peirates-linux-amd64/peirates /usr/bin
RUN rm -rf /tmp/*


# Switch user
USER $USERNAME
RUN mkdir -p ~/.kube
RUN echo "alias k=kubectl" >> ~/.bashrc

# Download kubescape configs (default into home's user)
RUN kubescape download artifacts
RUN kubescape download framework  AllControls

CMD ["/bin/bash"]

