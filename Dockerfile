# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# FROM gcr.io/distroless/static-debian12:nonroot as default

# # TARGETOS and TARGETARCH are set automatically when --platform is provided.
# ARG TARGETOS
# ARG TARGETARCH
# ARG PRODUCT_VERSION
# ARG BIN_NAME

# LABEL name="http-echo" \
#       maintainer="HashiCorp Consul Team <consul@hashicorp.com>" \
#       vendor="HashiCorp" \
#       version=$PRODUCT_VERSION \
#       release=$PRODUCT_VERSION \
#       summary="A test webserver that echos a response. You know, for kids." 

# COPY dist/$TARGETOS/$TARGETARCH/$BIN_NAME /

# EXPOSE 5678/tcp

# ENV ECHO_TEXT="hello-world"

# ENTRYPOINT ["/http-echo"]




# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

FROM gcr.io/distroless/static-debian12:nonroot as default

# TARGETOS and TARGETARCH are set automatically when --platform is provided.
ARG TARGETOS
ARG TARGETARCH
ARG PRODUCT_VERSION
ARG BIN_NAME

LABEL name="http-echo" \
      maintainer="HashiCorp Consul Team <consul@hashicorp.com>" \
      vendor="HashiCorp" \
      version=$PRODUCT_VERSION \
      release=$PRODUCT_VERSION \
      summary="A test webserver that echos a response. You know, for kids."

# Set a default value for BIN_NAME if not provided
ARG BIN_NAME=http-echo

# Define the source directory for COPY command
ARG SOURCE_DIR=dist/$TARGETOS/$TARGETARCH

# Set the working directory
WORKDIR /

# Copy the binary from the specified directory to the root directory
COPY $SOURCE_DIR/$BIN_NAME /$BIN_NAME

EXPOSE 5678/tcp

ENV ECHO_TEXT="hello-world"

ENTRYPOINT ["/http-echo"]
