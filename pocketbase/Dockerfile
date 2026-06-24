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

# Copy your local static website files into pb_public
COPY ./pb_public /pb/pb_public

# Copy your javascript hooks
COPY ./pb_hooks /pb/pb_hooks

# (Opsional) Uncomment baris di bawah ini jika Anda ingin mengunggah pb_migrations juga
# COPY ./pb_migrations /pb/pb_migrations

# Set working directory so PocketBase finds pb_hooks and pb_data correctly
WORKDIR /pb

# Expose port 8080 (Standar Railway)
EXPOSE 8080

# Mulai PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
