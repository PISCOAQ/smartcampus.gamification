# syntax=docker/dockerfile:experimental
FROM maven:3-openjdk-11 as mvn
COPY ./game-engine.core /tmp/game-engine.core
COPY ./game-engine.web /tmp/game-engine.web
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y nodejs npm git && rm -rf /var/lib/apt/lists/*
RUN npm install -g bower
WORKDIR /tmp/game-engine.core
RUN cd /tmp/game-engine.web/src/main/resources/consoleweb-assets && bower --allow-root install
RUN --mount=type=cache,target=/root/.m2,source=/.m2,from=smartcommunitylab/gamification-engine:cache mvn install -DskipTests
WORKDIR /tmp/game-engine.web
RUN --mount=type=cache,target=/root/.m2,source=/.m2,from=smartcommunitylab/gamification-engine:cache mvn install -DskipTests

FROM eclipse-temurin:11-alpine
ARG VER=3.0.0
ENV FOLDER=/tmp/target
ENV APP=game-engine.web
ENV VER=${VER}
# No adduser/addgroup: avoids "permission denied" in rootless Docker/Podman builds.
# Runtime user is enforced by Kubernetes securityContext.runAsUser (e.g. 10000).
WORKDIR /app
COPY --from=mvn /tmp/game-engine.web/target/${APP}.jar /app
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar ${APP}.jar --spring.profiles.active=sec"]
