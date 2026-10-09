FROM clojure:openjdk-17-lein AS builder
WORKDIR /app
COPY project.clj ./
RUN lein deps
COPY . .
RUN lein uberjar

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*standalone.jar /app/app.jar
EXPOSE 3012
CMD ["java", "-jar", "/app/app.jar"]