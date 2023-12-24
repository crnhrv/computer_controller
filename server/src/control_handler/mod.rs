use std::{
    error::Error,
    io::{self, BufReader, Read},
    net::TcpStream,
};

#[cfg(target_os = "windows")]
use crate::windows_keypress_handler::WindowsKeypressHandler as KeypressHandler;

#[cfg(target_os = "macos")]
use crate::macos_keypress_handler::MacOsKeypressHandler as KeypressHandler;

use byteorder::{LittleEndian, ReadBytesExt};

pub struct ControlHandler {}

impl ControlHandler {
    pub fn new() -> ControlHandler {
        ControlHandler {}
    }

    pub fn handle_connection(&self, stream: TcpStream) -> Result<(), Box<dyn Error>> {
        println!("Received control connection");
        let keypress_handler = KeypressHandler::new();
        loop {
            let mut buf_reader = BufReader::new(&stream);
            let header: ControlRequestHeader =
                ControlRequestHeader::from_reader(&mut buf_reader)?;
            let payload_size: usize = header.size as usize;
            let _payload_buf = vec![0u8; payload_size];

            // currently we don't support anything but a single key input
            // but we don't want to stall if we get more
            if payload_size != 1 {
                println!("RECEIVED MALFORMED COMMAND");
                let mut payload_buf = vec![0u8; payload_size];
                println!("READING {} bytes", payload_size);
                buf_reader.read_exact(&mut payload_buf)?;
                println!("finished reading");
                continue;
            }
            
            match header.mode {
                ControlMode::Keypress => {
                    let key = buf_reader.read_u8()?;
                    keypress_handler.handle_keypress(key)?;
                }
                ControlMode::MouseClick => todo!(),
                ControlMode::MouseMovement => todo!(),
            };
        }
    }
}

#[derive(Debug)]
#[repr(u8)]
enum ControlMode {
    Keypress = 1,
    MouseClick = 2,
    MouseMovement = 3,
}

impl From<u8> for ControlMode {
    fn from(value: u8) -> Self {
        match value {
            1 => ControlMode::Keypress,
            2 => ControlMode::MouseClick,
            3 => ControlMode::MouseMovement,
            _ => ControlMode::Keypress,
        }
    }
}

#[derive(Debug)]
struct ControlRequestHeader {
    mode: ControlMode,
    size: u32,
}

impl ControlRequestHeader {
    fn from_reader(rdr: &mut impl Read) -> io::Result<Self> {
        let mode = rdr.read_u8()?;
        let size = rdr.read_u32::<LittleEndian>()?;
        let mode = ControlMode::from(mode);
        Ok(ControlRequestHeader { mode, size })
    }
}
