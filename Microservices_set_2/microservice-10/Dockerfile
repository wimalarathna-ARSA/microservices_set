FROM hseeberger/scala-sbt:17.0.2_1.6.2_2.13.8
WORKDIR /app
COPY build.sbt ./
COPY project/ ./project/
RUN sbt update || true
COPY . .
RUN sbt compile || true
EXPOSE 3010
CMD ["sbt", "run"]
