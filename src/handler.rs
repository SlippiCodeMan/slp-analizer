use bytes::Buf;

use peppi::parse::Opts;
use peppi::game::Game;

use serde::{Serialize, Deserialize};

pub fn handle_message(msg: &str) -> String {
    match serde_json::from_str::<ClientMessage>(&msg) {
        Ok(msg) => {
            match &msg.t[..] {
                "get" => {
                    let resp = match download_game(&msg) {
                        Ok(game) => ServerMessage {
                            t: "done".to_string(),
                            slp_url: Some(msg.slp_url),
                            data: Some(SlpData::new(game)),
                        },
                        Err(_err) => ServerMessage {

                            t: "slp_error".to_string(),
                            slp_url: Some(msg.slp_url),
                            data: None,
                        }
                    };
                    serde_json::to_string(&resp).unwrap()
                },
                _ => {
                    let resp = ServerMessage {
                        t: "unknown_command".to_string(),
                        slp_url: Some(msg.slp_url),
                        data: None,
                    };
                    serde_json::to_string(&resp)
                        .unwrap_or(String::from("{}"))
                }
            }
        },
        Err(_err) => {
            let resp = ServerMessage {
                t: "json_error".to_string(),
                slp_url: None,
                data: None,
            };
            serde_json::to_string(&resp)
                .unwrap_or(String::from("{}"))
        }
    }
}

fn download_game(msg: &ClientMessage) -> Result<Game, Box<dyn std::error::Error>> {
    let mut buf = reqwest::blocking::get(&msg.slp_url)?
        .bytes()?
        .reader();

    Ok(
        peppi::game(&mut buf, Some(Opts { skip_frames: true }))?
    )
}


#[derive(Serialize)]
pub struct SlpData {
    #[serde(flatten)]
    game: Game,
}

impl SlpData {
    pub fn new(game: Game) -> SlpData {
        SlpData {
            game,
        }
    }
}

#[derive(Deserialize)]
pub struct ClientMessage {
    pub t: String,
    pub slp_url: String,
}

#[derive(Serialize)]
pub struct ServerMessage {
    pub t: String,
    pub slp_url: Option<String>,
    pub data: Option<SlpData>,
}
