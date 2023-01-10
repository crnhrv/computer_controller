extern crate core;

use clap::Parser;

pub mod tcp_server;
pub mod windows_control_handler;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Address to bind the server to
    #[arg(short, long, default_value = "192.168.0.16")]
    address: String,

    /// Port to bind the server to
    #[arg(short, long, default_value_t = 8244)]
    port: u16,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();

    tcp_server::start_server(args.port, &args.address)?;

    Ok(())
}
