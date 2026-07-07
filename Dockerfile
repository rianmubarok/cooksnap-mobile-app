FROM alpine:3.19

# Build args
ARG PB_VERSION=0.24.0

# Install dependencies
RUN apk add --no-cache \
    unzip \
    ca-certificates

# Download and unzip PocketBase
ADD https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip /tmp/pb.zip
RUN unzip /tmp/pb.zip -d /pb/

# Copy static files dari subfolder pocketbase/
COPY pocketbase/pb_public /pb/pb_public
COPY pocketbase/pb_hooks /pb/pb_hooks

# Copy startup script
COPY start.sh /pb/start.sh
RUN chmod +x /pb/start.sh

# Set working directory
WORKDIR /pb

# Expose port 8080
EXPOSE 8080

# Jalankan startup script (auto-create superuser jika env var tersedia, lalu start PocketBase)
CMD ["/pb/start.sh"]
