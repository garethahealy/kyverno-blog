FROM quay.io/redhat-cop/jenkins-agent-python:v1.0

USER root

RUN dnf install --assumeyes --nodocs tar wget python3 git findutils diffutils bc && \
    dnf clean all && \
    tar --version && \
    wget --version && \
    python3 --version && \
    git --version && \
    diff --version && \
    bc --version

RUN mkdir -p /tmpcmds
RUN export BATS_VERSION=master && \
    wget --no-verbose https://github.com/bats-core/bats-core/archive/${BATS_VERSION}.tar.gz && \
    tar -C /tmpcmds -xzf ${BATS_VERSION}.tar.gz && \
    /tmpcmds/bats-core-${BATS_VERSION}/install.sh /opt/bats && \
    ln -s /opt/bats/bin/bats /usr/local/bin/bats && \
    bats --version

RUN export JQ_VERSION=1.6 && \
    wget --no-verbose --directory-prefix=/tmpcmds https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 && \
    chmod +x /tmpcmds/jq-linux64 && \
    ln -s /tmpcmds/jq-linux64 /usr/local/bin/jq && \
    jq --version

RUN export OC_VERSION=4.7.0 && \
    wget --no-verbose https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz && \
    tar -C /tmpcmds -xzf openshift-client-linux.tar.gz && \
    ln -s /tmpcmds/oc /usr/local/bin/oc && \
    ln -s /tmpcmds/kubectl /usr/local/bin/kubectl && \
    oc version && \
    kubectl version

RUN export KYVERNO_VERSION=v1.4.2 && \
    wget --no-verbose https://github.com/kyverno/kyverno/releases/download/${KYVERNO_VERSION}/kyverno-cli_${KYVERNO_VERSION}_linux_x86_64.tar.gz && \
    tar -C /tmpcmds -xzf kyverno-cli_${KYVERNO_VERSION}_linux_x86_64.tar.gz && \
    ln -s /tmpcmds/kyverno /usr/local/bin/kyverno && \
    kyverno --help

RUN pip3 install yq && \
    yq --version

USER 1001