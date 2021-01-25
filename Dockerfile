FROM jameskilroe/gliderlabs:latest AS builder
RUN apk add --no-cache --update go build-base git mercurial ca-certificates
RUN mkdir -p /go/src/github.com/gliderlabs && \
    cp -r /src /go/src/github.com/gliderlabs/logspout

WORKDIR /go/src/github.com/gliderlabs/logspout
ARG ARCH=amd64
ARG OS=linux
ENV GOARCH=${ARCH}
ENV GOOS=${OS}
ENV CGO_ENABLED=0

COPY ./go.mod ./go.sum ./
RUN go mod download

# Import the code from the context.
COPY ./ ./

RUN go version
RUN go build -ldflags "-X main.Version=$(cat VERSION)-logdna" -o /bin/logspout


FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /bin/logspout /bin/logspout
ARG VERSION
ENV BUILD_VERSION=${VERSION}
VOLUME /mnt/routes
EXPOSE 80
ENTRYPOINT ["/bin/logspout"]