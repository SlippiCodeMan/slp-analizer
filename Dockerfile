FROM rust as builder
WORKDIR app
COPY . .
RUN cargo build --release

FROM rust as runtime
WORKDIR app
COPY --from=builder /app/target/release/app /usr/local/bin
ENTRYPOINT ["./usr/local/bin/app"]
