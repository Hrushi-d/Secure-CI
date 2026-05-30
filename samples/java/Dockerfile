# Multi-stage build — self-contained, no host build step required.
# Stage 1: build the JAR inside Docker so `docker build` works from scratch.
FROM eclipse-temurin:17-jdk-jammy@sha256:f7b969d455abeefb9cad0280477e067d8340c22a081347a94c6fe22d0c67d420 AS build
WORKDIR /src
COPY pom.xml ./
COPY src ./src
# Use the wrapper-less maven image trick: install once into this layer
RUN apt-get update && apt-get install -y --no-install-recommends maven \
    && rm -rf /var/lib/apt/lists/* \
    && mvn -B -DskipTests package

# Stage 2: minimal runtime image.
FROM eclipse-temurin:17-jre-jammy@sha256:8a21b8680d754f9f953b8285fb140879979a3b1fe038c1491df6dc0f9a04a1d3
WORKDIR /app
COPY --from=build /src/target/sample-app-0.1.0.jar /app/app.jar
USER 1001
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
