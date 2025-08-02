#!/bin/bash
# MinIO bucket initialization script
# This script creates the default bucket if it doesn't exist

set -e

# Wait for MinIO to be ready
echo "Waiting for MinIO to start..."
while ! curl -f http://localhost:9000/minio/health/live > /dev/null 2>&1; do
    sleep 2
done

echo "MinIO is ready, checking bucket..."

# Set MinIO client alias
mc alias set localminio http://localhost:9000 ${MINIO_ROOT_USER:-minioadmin} ${MINIO_ROOT_PASSWORD:-minioadmin123}

# Create bucket if it doesn't exist
BUCKET_NAME=${MINIO_DEFAULT_BUCKETS:-likha-licensing-docs}
if ! mc ls localminio/$BUCKET_NAME > /dev/null 2>&1; then
    echo "Creating bucket: $BUCKET_NAME"
    mc mb localminio/$BUCKET_NAME
    echo "Setting bucket policy to public read for development"
    mc anonymous set public localminio/$BUCKET_NAME
else
    echo "Bucket $BUCKET_NAME already exists"
fi

echo "MinIO initialization completed"