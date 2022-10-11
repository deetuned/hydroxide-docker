################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
######
######
######	Dockerfile for Hydroxide / Proton Mail Server
######
######
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
###### Build Hydroxide
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Builder OS
FROM golang:1-alpine as builder

ARG APP_VERSION=0.2.24
WORKDIR /src

# Build Hydroxide binary, releases preferred for stability, source compile chosen for compatibility and security
RUN if [ "${APP_VERSION}" = "latest" ]; then \
      apk add --no-cache curl; \
      RELEASE=$(curl --silent \
          "https://api.github.com/repos/emersion/hydroxide/releases" | \
          grep '"tag_name":' | \
          sed -E 's/.*"v([^"]+)".*/\1/' | \
          sort -Vr | head -n 1); \
    else \
      RELEASE=${APP_VERSION}; \
    fi \
    && RELEASES="https://github.com/emersion/hydroxide/releases/download" \
    && RELEASE_ARCHIVE="v${RELEASE}/hydroxide-${RELEASE}.tar.gz" \
    && wget -c "${RELEASES}/${RELEASE_ARCHIVE}" -qO - | tar -xz --strip 1 \
    && go get -d ./cmd/hydroxide \
    && go build -o hydroxide ./cmd/hydroxide

################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
###### Copy to container
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# Container OS
FROM alpine:3.16 as runner

LABEL org.opencontainers.image.title="Docker Hydroxide"
LABEL org.opencontainers.image.description="Containerised version of Hydroxide, the FOSS alternative to ProtonMail's Bridge application. Authenticates and exposes SMTP, IMAP, and CalDAV interfaces."
LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.authors="10679234+arichtman@users.noreply.github.com;Harley Lang"
LABEL org.opencontainers.image.source="https://github.com/harleylang/hydroxide-docker"

ARG USER=hydroxide
ARG UID=1000
ARG GID=1000

# SMTP IMAP CalDAV
EXPOSE 1025 1143 8080

WORKDIR /hydroxide

USER root

# Create service principal objects and adjust the umask to protect any credentials stored to disk.
RUN addgroup -g $UID -S "${USER}" && \
    adduser -D -u $UID -S "${USER}" -G "${USER}" -s /bin/ash/ && \
    sed -i 's/umask 022/umask 037/g' /etc/profile

# Copy Hydroxide and wrapper script
COPY --from=builder /src/hydroxide .
COPY ./start.sh .

RUN chown -R hydroxide:hydroxide /hydroxide

USER hydroxide

ENTRYPOINT [ "/bin/ash", "-l", "-c", "./start.sh ${EMAIL} ${PASSWORD} ${TOKEN}" ]
