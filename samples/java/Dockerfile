# Multi-stage build — self-contained, no host build step required.
# Stage 1: build the JAR inside Docker so `docker build` works from scratch.
FROM eclipse-temurin:25-jdk-jammy@sha256:7bb4493421ff8fe7d0361d0518e5abf0026fc6ac774ecdf28bb6b90d4fd4c4f8 AS build
WORKDIR /src
COPY pom.xml ./
COPY src ./src
# Use the wrapper-less maven image trick: install once into this layer
RUN apt-get update && apt-get install -y --no-install-recommends maven \
    && rm -rf /var/lib/apt/lists/* \
    && mvn -B -DskipTests package

# Stage 2: minimal runtime image.
FROM eclipse-temurin:25-jre-jammy@sha256:c3e62cd0cece58d8de8d760ab95a5014f3b5a6ea32178f54270edb5b4aab9d1f
WORKDIR /app
COPY --from=build /src/target/sample-app-0.1.0.jar /app/app.jar
USER 1001
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
