# select image
FROM rust:1.34-slim-stretch as builder

RUN apt-get update && apt-get install -y libdbus-1-dev

# create a new empty shell project
RUN USER=root cargo new --bin wifi-connect
WORKDIR /wifi-connect

# copy over your manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# this build step will cache your dependencies
RUN cargo build --release
RUN rm src/*.rs

# copy your source tree
COPY ./src ./src

# build for release
RUN rm ./target/release/deps/wifi_connect*
RUN cargo build --release

FROM debian:stretch-slim

RUN apt-get update && apt-get install -y dnsmasq wireless-tools

WORKDIR /usr/src/app

COPY --from=builder /wifi-connect/target/release/wifi-connect .

COPY scripts/start.sh .

CMD ["bash", "start.sh"]
