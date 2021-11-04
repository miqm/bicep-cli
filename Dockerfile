FROM python:3.9.7-slim

LABEL maintainer="miqm"

CMD ["/bin/bash"]

RUN apt-get update \
 && apt-get install -y ssh ca-certificates jq curl openssl perl git zip bash-completion apt-transport-https lsb-release gnupg wget busybox \
 && update-ca-certificates

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/azure-cli.list

ARG AZCOPY_VERSION_MAJOR=10
ARG AZCOPY_VERSION=10.13.0
RUN wget --content-disposition https://aka.ms/downloadazcopy-v${AZCOPY_VERSION_MAJOR}-linux \
 && tar -xf azcopy_linux_amd64_${AZCOPY_VERSION}.tar.gz --strip-components=1 \
 && cp ./azcopy /usr/local/bin/

ARG YQ_VERSION=4.13.5
RUN curl -o /usr/bin/yq -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 && chmod +x /usr/bin/yq

ARG CLI_VERSION=2.29.1
RUN apt-get update && apt-get install -y azure-cli=${CLI_VERSION}-1~$(lsb_release -c -s) 

RUN rm -rf /var/lib/apt/lists/*

ARG BICEP_VERSION=0.4.1008
RUN az bicep install --version=v${BICEP_VERSION} && cp $HOME/.azure/bin/bicep /usr/bin/bicep
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

RUN az extension add --name application-insights
RUN az extension add --name managementpartner
RUN az extension add --name front-door
