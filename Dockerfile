
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

# # Create directory structure
# RUN mkdir -p /dist/$TARGETOS/$TARGETARCH

# COPY dist/$TARGETOS/$TARGETARCH/$BIN_NAME /

# EXPOSE 5678/tcp

# ENV ECHO_TEXT="hello-world"

# ENTRYPOINT ["/http-echo"]



# Stage 1: Build the executable
FROM golang:latest AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files
COPY go.mod go.sum ./

# Download and install dependencies
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go binary
RUN go build -o http-echo .

# Stage 2: Create the minimal runtime container
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the binary from the build stage to the runtime container
COPY --from=build /app/http-echo .

# Expose any necessary ports
EXPOSE 5678

# Command to run the executable
CMD ["./http-echo"]

