# Multi-stage build — self-contained, no host build step required.
# Stage 1: build the JAR inside Docker so `docker build` works from scratch.
FROM eclipse-temurin:22-jdk-jammy@sha256:d8e6ba486df17bf758888d2b1b608133d1eedca8daf69d3fc6bf78d8be81e07e AS build
WORKDIR /src
COPY pom.xml ./
COPY src ./src
# Use the wrapper-less maven image trick: install once into this layer
RUN apt-get update && apt-get install -y --no-install-recommends maven \
    && rm -rf /var/lib/apt/lists/* \
    && mvn -B -DskipTests package

# Stage 2: minimal runtime image.
FROM eclipse-temurin:22-jre-jammy@sha256:dbcae8b5dd4d63f81739a538ec2c09797735f04a21d814f9071b62f018326043
WORKDIR /app
COPY --from=build /src/target/sample-app-0.1.0.jar /app/app.jar
USER 1001
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
