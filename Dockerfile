# Stage 1: Build the artifact using the exact required tool versions
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Copy the pom.xml and fetch dependencies to leverage caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and compile the fat JAR
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Create the lightweight runtime environment
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Pull the compiled JAR directly from the build stage
COPY --from=build /app/target/student.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
