FROM rust as planner
WORKDIR slp-analyzer
# We only pay the installation cost once, 
# it will be cached from the second build onwards
# To ensure a reproducible build consider pinning 
# the cargo-chef version with `--version X.X.X`
RUN cargo install cargo-chef 
COPY . .
RUN cargo chef prepare  --recipe-path recipe.json

FROM rust as cacher
WORKDIR slp-analyzer
RUN cargo install cargo-chef
COPY --from=planner /slp-analyzer/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

FROM rust as builder
WORKDIR slp-analyzer
COPY . .
# Copy over the cached dependencies
COPY --from=cacher /slp-analyzer/target target
COPY --from=cacher /usr/local/cargo /usr/local/cargo
RUN cargo build --release 

FROM rust as runtime
WORKDIR slp-analyzer
COPY --from=builder /slp-analyzer/target/release/slp-analyzer /usr/local/bin
ENTRYPOINT ["/usr/local/bin/slp-analyzer"]
