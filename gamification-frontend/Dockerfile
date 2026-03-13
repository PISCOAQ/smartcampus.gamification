# syntax=docker/dockerfile:experimental
FROM node:14 AS react-build
ARG  REACT_APP_API_ENDPOINT=http://localhost:8010/gamification
WORKDIR /app
COPY public /app/public
COPY src /app/src
COPY .env /app/
COPY package*.json ./
COPY tsconfig.json ./
RUN --mount=type=cache,target=/app/node_modules/,source=/node_modules/,from=smartcommunitylab/gamification-engine-frontend:cache npm install
RUN --mount=type=cache,target=/app/node_modules/,source=/node_modules/,from=smartcommunitylab/gamification-engine-frontend:cache npm run build

FROM ghcr.io/nginx/nginx-unprivileged:1.29.5-alpine
# No adduser/addgroup: avoids "permission denied" in rootless Docker/Podman builds.
# Runtime user is enforced by Kubernetes securityContext.runAsUser; base image already runs as nginx.
COPY frontend.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/
COPY --from=react-build /app/build /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]