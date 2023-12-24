use std::mem::size_of;
use std::os::raw::c_int;
use std::error::Error,

use winapi::shared::minwindef::WORD;
use winapi::um::winuser::{
    INPUT_u, SendInput, INPUT, INPUT_KEYBOARD, KEYBDINPUT, KEYEVENTF_KEYUP, LPINPUT,
};

pub struct WindowsKeypressHandler {}

impl WindowsKeypressHandler {
    pub fn new() -> WindowsKeypressHandler {
        WindowsKeypressHandler {}
    }

    pub fn handle_keypress(&self, key: u8) -> Result<(), Box<dyn Error>> {
        self.send_input(0, key)?;
        self.send_input(KEYEVENTF_KEYUP, key)?;

        Ok(())
    }

    fn send_input(&self, flags: u32, key: u8) -> Result<(), Box<dyn Erorr>> {
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
    }
}


