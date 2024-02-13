FROM python:3.10.13-slim-bullseye

LABEL maintainer="miqm"

CMD ["/bin/bash"]

RUN apt-get update \
    && apt-get install -y ssh ca-certificates jq curl openssl perl git zip bash-completion apt-transport-https lsb-release gnupg wget busybox bc iputils-tracepath iputils-ping \
    && update-ca-certificates && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG AZCOPY_VERSION_MAJOR=10
ARG AZCOPY_VERSION=10.23.0
RUN mkdir /tmp/azcopy && cd /tmp/azcopy && wget --content-disposition https://aka.ms/downloadazcopy-v${AZCOPY_VERSION_MAJOR}-linux \
    && tar -xf azcopy_linux_amd64_${AZCOPY_VERSION}.tar.gz --strip-components=1 \
    && mv ./azcopy /usr/local/bin/ && cd / && rm -rf /tmp/azcopy

ARG YQ_VERSION=4.40.7
RUN curl -o /usr/local/bin/yq -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 && chmod +x /usr/local/bin/yq

ARG SPRUCE_VERSION=1.31.0
RUN curl -o /usr/local/bin/spruce -L https://github.com/geofffranks/spruce/releases/download/v${SPRUCE_VERSION}/spruce-linux-amd64 && chmod +x /usr/local/bin/spruce

ARG TFENV_VERSION=3.0.0
RUN mkdir -p /usr/local/lib/tfenv \
    && curl -o /tmp/tfenv.tar.gz -L https://github.com/tfutils/tfenv/archive/refs/tags/v${TFENV_VERSION}.tar.gz \
    && tar -zxf /tmp/tfenv.tar.gz -C /usr/local/lib/tfenv --strip-components=1 \
    && rm /tmp/tfenv.tar.gz \
    && ln -s /usr/local/lib/tfenv/bin/* /usr/local/bin/ \
    && tfenv install && tfenv use

ARG HELM_VERSION=3.14.0
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
    && apt-get update && apt-get install -y helm && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG CLI_VERSION=2.57.0
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update && apt-get install -y azure-cli=${CLI_VERSION}-1~$(lsb_release -c -s) && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG BICEP_VERSION=0.25.53
ARG KUBECTL_VERSION=1.28.3
ARG KUBELOGIN_VERSION=0.1.0

RUN az bicep install --version=v${BICEP_VERSION} \
    && mv $HOME/.azure/bin/bicep /usr/bin/bicep && ln -s /usr/bin/bicep $HOME/.azure/bin/bicep \
    && az extension add --name application-insights \
    && az extension add --name managementpartner \
    && az extension add --name front-door \
    && az aks install-cli --client-version=${KUBECTL_VERSION} --kubelogin-version=${KUBELOGIN_VERSION} \
    && rm -rf $HOME/.azure/telemetry/cache $HOME/.azure/logs/* \
    && cp -r $HOME/.azure /etc/skel/

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    AZURE_BICEP_USE_BINARY_FROM_PATH=1
