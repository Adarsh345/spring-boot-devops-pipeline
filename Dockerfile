# ============================================================================
# Stage 1: Build Stage
# ============================================================================
# This is a "multi-stage" build - it builds the app, then discards build tools
# WHY: Docker images are smaller because we don't include Maven in final image

FROM maven:3.9-eclipse-temurin-21 AS builder

# Set working directory inside container
WORKDIR /app

# Copy pom.xml first (Maven dependencies - cached if unchangedchanged)
COPY pom.xml .

# Download dependencies
RUN mvn dependency:resolve -DskipTests

# Copy source code
COPY src ./src

# Build the application (creates JAR file)
RUN mvn clean package -DskipTests

# ============================================================================
# Stage 2: Runtime Stage
# ============================================================================
# This stage is much smaller - only contains Java and our JAR file

FROM eclipse-temurin:21-jre-alpine

# WHY Alpine? It's tiny (~100MB vs ~500MB for standard Java image)

# Set working directory
WORKDIR /app

# Create non-root user for security (containers shouldn't run as root)
RUN addgroup -g 1000 appgroup && adduser -D -u 1000 -G appgroup appuser

# Copy built JAR from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Set ownership to non-root user
RUN chown appuser:appgroup /app && chown appuser:appgroup /app/app.jar

# Switch to non-root user
USER appuser

# Expose port (documentation - doesn't actually open port)
EXPOSE 8080

# Health check - Kubernetes will use this to know if app is healthy
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/api/status || exit 1

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

# CMD allows default arguments (can be overridden)
CMD ["--server.port=8080"]
