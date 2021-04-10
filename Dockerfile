ARG CRYSTAL_VERSION=0.35.1-alpine
FROM crystallang/crystal:${CRYSTAL_VERSION} AS builder

WORKDIR /Mango

COPY . .

RUN apk add --no-cache \
  yarn yaml sqlite-static \
  libarchive-dev libarchive-static \
  acl-static expat-static zstd-static \
  lz4-static bzip2-static libjpeg-turbo-dev \
  libpng-dev tiff-dev

RUN make static || make static

FROM library/alpine:latest

# Create a group and user
RUN addgroup -g 1000 mango \
  && adduser -u 1000 -G mango -h /home/mango -D mango

# Set the default user to run commands, everything ran after this line will be run as normal user
USER mango:mango

# Copy compiled binary from build step
COPY --from=builder /Mango/mango /usr/local/bin/mango

CMD ["/usr/local/bin/mango"]
