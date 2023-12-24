use std::error::Error;
use enigo::{Enigo, Key, KeyboardControllable};

pub struct MacOsKeypressHandler {}

impl MacOsKeypressHandler {
    pub fn new() -> MacOsKeypressHandler {
        MacOsKeypressHandler {}
    }

    pub fn handle_keypress(&self, key: u8) -> Result<(), Box<dyn Error>> {

        let key = Self::convert_keypress(key);

        let mut enigo = Enigo::new();

        enigo.key_click(key);
        println!("Pressed key: {:?} at {:?}", key, chrono::Utc::now().format("%H:%M:%S").to_string());
        Ok(())
    }

    fn convert_keypress(key: u8) -> Key {
        return match key {
            0x20 => Key::Raw(0x31), // space
            0x46 => Key::Raw(0x03), // f key
            0x56 => Key::Raw(0x09), // v key
            0x25 => Key::Raw(0x56), // left arrow key 
            0x26 => Key::Raw(0x5B), // up arrow key          
            0x27 => Key::Raw(0x58), // right arrow key
            0x28 => Key::Raw(0x54), // down arrow key
            0x22 => Key::Raw(0x79), // page down key
            0x21 => Key::Raw(0x74), // page up key
            0xAF => Key::Raw(0x43), // volume up key
            0xAE => Key::Raw(0x4B), // volume down key
            0xAD => Key::Raw(0x18), // mute key
            0xB3 => Key::Raw(0x31), // play/pause key
            0xB1 => Key::Raw(0x5C), // previous track key
            0xB0 => Key::Raw(0x59), // next track key
            _ => panic!("Key not supported: {:x}", key),
        };
    }
}


