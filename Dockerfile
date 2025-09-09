ARG PYTHON_VERSION=latest
FROM python:${PYTHON_VERSION}

LABEL maintainer="miqm"

CMD ["/bin/bash"]

SHELL ["/bin/bash", "-c"]

ARG YQ_VERSION=4.47.1

ARG SPRUCE_VERSION=1.31.1

ARG TFENV_VERSION=3.0.0

ARG HELM_VERSION=3.18.6

ARG AZCOPY_VERSION=10.30.0

ARG CLI_VERSION=2.75.0

ARG BICEP_VERSION=0.37.4

ARG KUBECTL_VERSION=1.28.3

ARG KUBELOGIN_VERSION=0.2.10

ARG PULUMI_VERSION=3.193.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends ssh ca-certificates jq curl openssl perl git zip unzip less bash-completion apt-transport-https lsb-release gnupg wget busybox bc iputils-tracepath iputils-ping \
    && update-ca-certificates && . /etc/os-release \
    && curl -o /usr/local/bin/yq -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 && chmod +x /usr/local/bin/yq \
    && curl -o /usr/local/bin/spruce -L https://github.com/geofffranks/spruce/releases/download/v${SPRUCE_VERSION}/spruce-linux-amd64 && chmod +x /usr/local/bin/spruce \
    && mkdir -p /usr/local/lib/tfenv && curl -o /tmp/tfenv.tar.gz -L https://github.com/tfutils/tfenv/archive/refs/tags/v${TFENV_VERSION}.tar.gz \
    && tar -zxf /tmp/tfenv.tar.gz -C /usr/local/lib/tfenv --strip-components=1 && rm /tmp/tfenv.tar.gz && ln -s /usr/local/lib/tfenv/bin/* /usr/local/bin/ && tfenv install && tfenv use \
    && curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
    && curl -fsSL https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o /tmp/packages-microsoft-prod.deb \
    && dpkg -i /tmp/packages-microsoft-prod.deb && rm /tmp/packages-microsoft-prod.deb \
    && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bookworm main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update && apt-get install -y azure-cli=${CLI_VERSION}-1~bookworm azcopy=${AZCOPY_VERSION} helm=${HELM_VERSION}-1 && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && az bicep install --version=v${BICEP_VERSION} \
    && mv $HOME/.azure/bin/bicep /usr/bin/bicep && ln -s /usr/bin/bicep $HOME/.azure/bin/bicep \
    && az extension add --name application-insights \
    && az extension add --name managementpartner \
    && az aks install-cli --client-version=${KUBECTL_VERSION} --kubelogin-version=${KUBELOGIN_VERSION} \
    && rm -rf $HOME/.azure/telemetry/cache $HOME/.azure/logs/* \
    && cp -r $HOME/.azure /etc/skel/ \
    && curl -fsSL https://get.pulumi.com | sh -s -- --version ${PULUMI_VERSION} --install-root /usr/local/lib/pulumi && ln -s /usr/local/lib/pulumi/bin/* /usr/local/bin

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    AZURE_BICEP_USE_BINARY_FROM_PATH=1
