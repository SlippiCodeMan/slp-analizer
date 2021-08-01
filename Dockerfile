FROM rust as builder
WORKDIR slp-analizer
COPY . .
RUN cargo build --release

FROM rust as runtime
WORKDIR app
COPY --from=builder /app/target/release/slp-analizer /usr/local/bin
ENTRYPOINT ["./usr/local/bin/slp-analizer"]
