# purpose: Kafka client
# author: Gary A. Stafford
# date: 2021-07-20

FROM openjdk:17-alpine3.14

RUN apk update && apk add --no-cache wget tar bash
#ENV AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')

ENV KAFKA_VERSION=2.8.0
ENV KAFKA_PACKAGE=kafka_2.13-2.8.0
ENV AWS_MSK_IAM_AUTH=1.1.0
ENV GLIBC_VER=2.33-r0

# install glibc compatibility for alpine and aws cli
# reference: https://github.com/aws/aws-cli/issues/4685#issuecomment-615872019
RUN apk --no-cache add \
        binutils \
        curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
        binutils \
        curl \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*

# setup truststore
RUN cp $JAVA_HOME/lib/security/cacerts /tmp/kafka.client.truststore.jks

# install kafka
RUN wget https://downloads.apache.org/kafka/$KAFKA_VERSION/$KAFKA_PACKAGE.tgz
RUN tar -xzf $KAFKA_PACKAGE.tgz
WORKDIR /$KAFKA_PACKAGE

# install aws-msk-iam-auth jar
RUN wget https://github.com/aws/aws-msk-iam-auth/releases/download/$AWS_MSK_IAM_AUTH/aws-msk-iam-auth-$AWS_MSK_IAM_AUTH-all.jar
RUN mv aws-msk-iam-auth-$AWS_MSK_IAM_AUTH-all.jar libs/

# Copy client properties file(s)
COPY client*.properties bin/

ENTRYPOINT ["sh"]
