FROM python:3.10.4-slim

LABEL maintainer="miqm"

CMD ["/bin/bash"]

RUN apt-get update \
 && apt-get install -y ssh ca-certificates jq curl openssl perl git zip bash-completion apt-transport-https lsb-release gnupg wget busybox bc \
 && update-ca-certificates

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/azure-cli.list

ARG AZCOPY_VERSION_MAJOR=10
ARG AZCOPY_VERSION=10.14.1
RUN wget --content-disposition https://aka.ms/downloadazcopy-v${AZCOPY_VERSION_MAJOR}-linux \
 && tar -xf azcopy_linux_amd64_${AZCOPY_VERSION}.tar.gz --strip-components=1 \
 && cp ./azcopy /usr/local/bin/

ARG YQ_VERSION=4.25.1
RUN curl -o /usr/bin/yq -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 && chmod +x /usr/bin/yq

ARG SPRUCE_VERSION=1.29.0
RUN curl -o /usr/bin/spruce -L https://github.com/geofffranks/spruce/releases/download/v${SPRUCE_VERSION}/spruce-linux-amd64 && chmod +x /usr/bin/spruce

ARG TFENV_VERSION=2.2.3
RUN mkdir -p /usr/local/lib/tfenv \
 && curl -o /tmp/tfenv.tar.gz -L https://github.com/tfutils/tfenv/archive/refs/tags/v${TFENV_VERSION}.tar.gz \
 && tar -zxf /tmp/tfenv.tar.gz -C /usr/local/lib/tfenv --strip-components=1 \
 && rm /tmp/tfenv.tar.gz \
 && ln -s /usr/local/lib/tfenv/bin/* /usr/local/bin/ \
 && tfenv install && tfenv use

ARG CLI_VERSION=2.36.0
RUN apt-get update && apt-get install -y azure-cli=${CLI_VERSION}-1~$(lsb_release -c -s) 

RUN rm -rf /var/lib/apt/lists/*

ARG BICEP_VERSION=0.6.11
RUN az bicep install --version=v${BICEP_VERSION} && cp $HOME/.azure/bin/bicep /usr/bin/bicep
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

RUN az extension add --name application-insights
RUN az extension add --name managementpartner
RUN az extension add --name front-door
