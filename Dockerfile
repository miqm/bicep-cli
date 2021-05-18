FROM python:3.9-slim

LABEL maintainer="miqm"

CMD ["/bin/bash"]

RUN apt-get update \
 && apt-get install -y ssh ca-certificates jq curl openssl perl git zip bash-completion apt-transport-https lsb-release gnupg wget \
 && update-ca-certificates

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ buster main" | tee /etc/apt/sources.list.d/azure-cli.list

ARG YQ_VERSION=4.7.0
RUN curl -o /usr/bin/yq -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 && chmod +x /usr/bin/yq

ARG CLI_VERSION=2.23.0
RUN apt-get update && apt-get install -y azure-cli=${CLI_VERSION}-1~buster && rm -rf /var/lib/apt/lists/*

ARG BICEP_VERSION=0.3.539
RUN az bicep install --version=v${BICEP_VERSION}

ARG AZCOPY_VERSION=10
RUN wget -O azcopy_v${AZCOPY_VERSION}.tar.gz https://aka.ms/downloadazcopy-v${AZCOPY_VERSION}-linux \
 && tar -xf azcopy_v${AZCOPY_VERSION}.tar.gz --strip-components=1 \
 && cp ./azcopy /usr/local/bin/

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
