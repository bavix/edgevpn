FROM golang:1.22-alpine3.19 as builder

RUN apk --no-cache add git &&\
    git clone --depth=1 https://github.com/mudler/edgevpn.git /tmp/edgevpn &&\
    cd /tmp/edgevpn &&\
    go build -v -ldflags "-s -w" -o /edgevpn &&\
    cd - &&\
    rm -rf /tmp/edgevpn

FROM alpine:3.19
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
