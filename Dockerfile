# Base image
FROM alpine:3.18.4
LABEL name=intense-security/k8s-audit-utils
LABEL maintainer="Intense Security"
LABEL version="1.1.3"

ARG USERNAME=pentester
RUN addgroup -S $USERNAME && adduser -S $USERNAME -G $USERNAME

# Moving to temp for downloads and installations.
WORKDIR /tmp
COPY ./malicious_pod.yml /tmp/

# gcompat for Goland errors when installing kubeaudit and others.
RUN apk update && apk add --no-cache bash wget git python3 curl gcompat sudo jq yq nmap net-tools tcpdump openssl nikto

# may the user need root sometimes
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME

# python3 as def
RUN ln -sf /usr/bin/python3 /usr/bin/python

# kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl && mv kubectl /usr/bin

# Openshift 4 oc client
RUN wget "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.13.13/openshift-client-linux-4.13.13.tar.gz"
RUN tar -xzf openshift-client-linux-4.13.13.tar.gz
RUN mv oc /usr/bin

# kubeaudit
RUN wget "https://github.com/Shopify/kubeaudit/releases/download/v0.22.0/kubeaudit_0.22.0_linux_amd64.tar.gz"
RUN tar -xzf kubeaudit_0.22.0_linux_amd64.tar.gz
RUN chmod +x ./kubeaudit && mv kubeaudit /usr/bin/
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
# update trivy's db for the first time: ghcr.io/aquasecurity/trivy-db
RUN trivy filesystem /tmp/

# Peirates
RUN wget https://github.com/inguardians/peirates/releases/download/v1.1.13/peirates-linux-amd64.tar.xz
RUN xzcat peirates-linux-amd64.tar.xz > peirates-linux-amd64.tar
RUN tar -xf peirates-linux-amd64.tar
RUN mv /tmp/peirates-linux-amd64/peirates /usr/bin

# Nuclei
RUN wget "https://github.com/projectdiscovery/nuclei/releases/download/v2.9.15/nuclei_2.9.15_linux_amd64.zip"
RUN unzip nuclei_2.9.15_linux_amd64.zip 
RUN mv nuclei /usr/bin/
RUN nuclei -ut

# Cleanup
RUN rm -rf /tmp/*

# Switch user
USER $USERNAME
RUN mkdir -p ~/.kube
RUN echo "alias k=kubectl" >> ~/.bashrc

# Download kubescape configs (default into home's user)
# Connections to: api.armosec.io and report.armo.cloud (-l debug)
RUN kubescape download artifacts
RUN kubescape download framework  AllControls

CMD ["/bin/bash"]

