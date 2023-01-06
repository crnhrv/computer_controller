use std::{
    error::Error,
    io::{self, BufReader, Read},
    net::TcpStream,
};

use byteorder::{LittleEndian, ReadBytesExt};
use winapi::um::winuser::keybd_event;

pub struct WindowsControlHandler {}

impl WindowsControlHandler {
    pub fn new() -> WindowsControlHandler {
        WindowsControlHandler {}
    }

    fn handle_keypress(&self, key: u8) -> Result<(), Box<dyn Error>> {
        unsafe { keybd_event(key, 0, 0, 0) };
        Ok(())
    }

    pub fn handle_connection(&self, stream: TcpStream) -> Result<(), Box<dyn Error>> {
        println!("Received control connection");
        loop {
            let mut buf_reader = BufReader::new(&stream);
            let header: WindowsControlRequestHeader =
                WindowsControlRequestHeader::from_reader(&mut buf_reader)?;
            let payload_size: usize = header.size as usize;
            let _payload_buf = vec![0u8; payload_size];

            match header.mode {
                WindowsControlMode::Keypress => &self.handle_keypress(buf_reader.read_u8()?),
                WindowsControlMode::MouseClick => todo!(),
                WindowsControlMode::MouseMovement => todo!(),
            };
        }
    }
}

#[derive(Debug)]
#[repr(u8)]
enum WindowsControlMode {
    Keypress = 1,
    MouseClick = 2,
    MouseMovement = 3,
}

impl From<u8> for WindowsControlMode {
    fn from(value: u8) -> Self {
        match value {
            1 => WindowsControlMode::Keypress,
            2 => WindowsControlMode::MouseClick,
            3 => WindowsControlMode::MouseMovement,
            _ => WindowsControlMode::Keypress,
        }
    }
}

#[derive(Debug)]
struct WindowsControlRequestHeader {
    mode: WindowsControlMode,
    size: u32,
}

impl WindowsControlRequestHeader {
    fn from_reader(rdr: &mut impl Read) -> io::Result<Self> {
        let mode = rdr.read_u8()?;
        let size = rdr.read_u32::<LittleEndian>()?;
        let mode = WindowsControlMode::from(mode);
        Ok(WindowsControlRequestHeader { mode, size })
    }
}
