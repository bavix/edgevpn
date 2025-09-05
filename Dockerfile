FROM golang:1.25-alpine3.22 as builder

LABEL org.opencontainers.image.source=https://github.com/mudler/edgevpn
LABEL org.opencontainers.image.description="⛵ The immutable, decentralized, statically built p2p VPN without any central server and automatic discovery! Create decentralized introspectable tunnels over p2p with shared tokens"
LABEL org.opencontainers.image.licenses=Apache-2.0

ARG version

RUN apk --no-cache add git &&\
    git clone --depth=1 --branch v0.31.1 https://github.com/mudler/edgevpn.git /tmp/edgevpn &&\
    cd /tmp/edgevpn &&\
    export commit=$(git rev-parse HEAD) &&\
    go build -v -ldflags "-s -w -X 'github.com/mudler/edgevpn/internal.Version=${version:-dev}' -X 'github.com/mudler/edgevpn/internal.Commit=${commit:-dev}'" -o /edgevpn &&\
    cd - &&\
    rm -rf /tmp/edgevpn

FROM alpine:3.22
WORKDIR /
ENV USER=edgevpn
ENV UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}" && \
    apk add --update --no-cache tzdata curl

COPY --from=builder /edgevpn .

ENTRYPOINT ["/edgevpn"]
