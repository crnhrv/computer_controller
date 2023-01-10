use crate::windows_control_handler::WindowsControlHandler;
use std::error::Error;
use std::net::{IpAddr, SocketAddr, TcpListener};
use std::str::FromStr;
use threadpool::ThreadPool;

pub fn start_server(port: u16, address: &str) -> Result<(), Box<dyn Error>> {
    let address = SocketAddr::new(IpAddr::from_str(address)?, port);
    let listener = TcpListener::bind(address)?;
    let pool = ThreadPool::new(5);

    println!("Binding to {}", listener.local_addr()?);

    for stream in listener.incoming() {
        let stream = stream.unwrap();
        let control_handler = WindowsControlHandler::new();
        pool.execute(move || {
            let result = control_handler.handle_connection(stream);
            match result {
                Ok(_) => (),
                Err(_) => println!("Connection closed abruptly"),
            };
        })
    }

    Ok(())
}
