use std::mem::size_of;
use std::os::raw::c_int;
use std::{
    error::Error,
    io::{self, BufReader, Read},
    net::TcpStream,
};

use byteorder::{LittleEndian, ReadBytesExt};
use winapi::shared::minwindef::WORD;
use winapi::um::winuser::{
    INPUT_u, SendInput, INPUT, INPUT_KEYBOARD, KEYBDINPUT, KEYEVENTF_KEYUP, LPINPUT,
};

pub struct WindowsControlHandler {}

impl WindowsControlHandler {
    pub fn new() -> WindowsControlHandler {
        WindowsControlHandler {}
    }

    fn handle_keypress(&self, flags: u32, key: u8) -> Result<(), Box<dyn Error>> {
        let keybd = KEYBDINPUT {
            wVk: key as WORD,
            wScan: 0,
            dwFlags: flags,
            time: 0,
            dwExtraInfo: 0,
        };

        let mut input_u: INPUT_u = unsafe { std::mem::zeroed() };

        unsafe {
            *input_u.ki_mut() = keybd;
        }

        let mut input = INPUT {
            type_: INPUT_KEYBOARD,
            u: input_u,
        };

        unsafe { SendInput(1, &mut input as LPINPUT, size_of::<INPUT>() as c_int) };

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
                WindowsControlMode::Keypress => {
                    let key = buf_reader.read_u8()?;
                    self.handle_keypress(0, key)?;
                    self.handle_keypress(KEYEVENTF_KEYUP, key)?;
                }
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
