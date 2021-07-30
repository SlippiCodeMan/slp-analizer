mod websocket;
mod handler;

use websocket::WebSocket;

use actix_web::{middleware, web, App, Error, HttpRequest, HttpResponse, HttpServer};
use actix_web_actors::ws;

async fn ws_index(r: HttpRequest, stream: web::Payload,) -> Result<HttpResponse, Error> {
    let res = ws::start(WebSocket::new(), &r, stream);
    res
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    std::env::set_var("RUST_LOG", "actix_server=info,actix_web=info,websocket=trace");
    env_logger::init();

    HttpServer::new(move || {
        App::new()
            .wrap(middleware::Logger::default())
            .service(web::resource("/").route(web::get().to(ws_index)))
    })
        .bind(("0.0.0.0", 9002))?
        .run()
        .await
}