# Multi-stage Dockerfile for Spring Boot Modulith with React Frontend
# Stage 1: Build the React frontend
FROM node:20-bullseye-slim AS frontend-builder

WORKDIR /frontend

# Copy frontend package files
COPY frontend/package*.json ./
RUN npm ci

# Copy frontend source code
COPY frontend/ ./

# Build the React application
RUN npm run build

# Stage 2: Build the Spring Boot application
FROM maven:3.9-eclipse-temurin-21 AS backend-builder

WORKDIR /app

# Copy pom.xml first for better Docker layer caching
COPY backend/pom.xml ./

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy backend source code
COPY backend/src ./src

# Copy built frontend assets to Spring Boot static resources
COPY --from=frontend-builder /frontend/dist ./src/main/resources/static

# Build the Spring Boot application (skip frontend build since we already have it)
RUN mvn clean package -DskipTests -Dfrontend.skip=true

# Stage 3: Runtime image
FROM eclipse-temurin:21-jre-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Create application user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# Copy the built JAR from builder stage
COPY --from=backend-builder /app/target/*.jar app.jar

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM optimization for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -XX:+UseStringDeduplication"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]