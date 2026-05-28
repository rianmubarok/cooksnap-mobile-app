FROM alpine:latest

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

# (Opsional) Uncomment baris di bawah ini jika Anda ingin mengunggah pb_migrations juga
# COPY ./pb_migrations /pb/pb_migrations

# Expose port 8080 (Standar Railway)
EXPOSE 8080

# Mulai PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
