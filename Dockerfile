FROM rust as builder
WORKDIR slp-analizer
COPY . .
RUN cargo build --release

FROM rust as runtime
WORKDIR slp-analizer
COPY --from=builder /slp-analizer/target/release/slp-analizer /usr/local/bin
ENTRYPOINT ["./usr/local/bin/slp-analizer"]
