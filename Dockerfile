FROM jenkinsci/blueocean:1.22.0

USER root

RUN set -ex \
    && RUN_DEPS=" \
        unzip \
        wget \
        curl \
        jq \
    " \
    && apk update && apk add $RUN_DEPS \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

RUN set -ex \
    && wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip \
    && unzip terraform_0.12.26_linux_amd64.zip \
    && mv ./terraform /usr/local/bin/terraform
