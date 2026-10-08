FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/microservice-03-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 3003
CMD ["java", "-jar", "app.jar"]
