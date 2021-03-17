FROM python:3.9
ENTRYPOINT /bin/bash
RUN mkdir -p /app
WORKDIR /app
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN az bicep install
