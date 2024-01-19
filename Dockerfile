FROM eclipse-temurin:17.0.7_7-jdk-jammy as builder

WORKDIR /jre-run

# create custom jre
RUN jlink --add-modules ALL-MODULE-PATH --output custom-jre-17 \
    --strip-debug --no-man-pages --no-header-files --compress=2

WORKDIR /source

COPY gradle gradle
COPY gradlew .

ARG NEXUS_USERNAME
ARG NEXUS_PASSWORD

ENV MAVEN_NEXUS_USER_MIA=$NEXUS_USERNAME
ENV MAVEN_NEXUS_TOKEN_MIA=$NEXUS_PASSWORD

# cache gradle binary
RUN ./gradlew --no-daemon

COPY settings.gradle.kts .

# cache service dependencies
RUN ./gradlew --no-daemon

COPY app app

# create the folder containing all the jar libraries
RUN ./gradlew installDist --no-daemon

RUN echo "template crud sql commit sha: $COMMIT_SHA" >> ./commit.sha

FROM ubuntu:22.04 as final

ARG VENDOR_NAME

LABEL maintainer="Mia-platform" \
      name="SQL CRUD" \
      description="" \
      version="" \
      eu.mia-platform.url="https://www.mia-platform.eu" \
      eu.mia-platform.language="kotlin"

ENV JAVA_HOME=/jre-run/custom-jre-17
ENV LOG_LEVEL=DEBUG
ENV HTTP_PORT=3000
ENV API_PORT=3001
ENV SWAGGER_PORT=5000
ENV TABLE_DEFINITION_FOLDER=/app/table-schemas
ENV DB_URL="db-url"

RUN apt-get update \
    && apt-get install -f tini -y \
    && apt-get clean autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

USER 1002

COPY --chown=1002 --from=builder /jre-run/custom-jre-17 /jre-run/custom-jre-17
COPY --chown=1002 --from=builder /source/app/build/install/app .
COPY --chown=1002 --from=builder /source/commit.sha /home/java/app/commit.sha

EXPOSE ${HTTP_PORT}


ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/sh", "-c", "bin/app"]

