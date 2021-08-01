FROM rust as planner
WORKDIR slp-analizer
# We only pay the installation cost once, 
# it will be cached from the second build onwards
# To ensure a reproducible build consider pinning 
# the cargo-chef version with `--version X.X.X`
RUN cargo install cargo-chef 
COPY . .
RUN cargo chef prepare  --recipe-path recipe.json

FROM rust as cacher
WORKDIR slp-analizer
RUN cargo install cargo-chef
COPY --from=planner /slp-analizer/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

FROM rust as builder
WORKDIR slp-analizer
COPY . .
# Copy over the cached dependencies
COPY --from=cacher /slp-analizer/target target
COPY --from=cacher /usr/local/cargo /usr/local/cargo
RUN cargo build --release 

FROM rust as runtime
WORKDIR slp-analizer
COPY --from=builder /slp-analizer/target/release/slp-analizer /usr/local/bin
ENTRYPOINT ["./usr/local/bin/slp-analizer"]
