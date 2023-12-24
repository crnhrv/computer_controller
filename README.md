### Windows Controller

A basic client (cross platform built with Flutter, with a focus on Android app), and server (Rust), which allow a user to send keyboard events over TCP to control a Windows or MacOS machine.

Currently the functionality is (very) limited to a few keys that I personally use for controlling playback in MPV from my phone.

This is primarily a personal development project & I don't expect anyone to use this. There are better options available for this kind of thing, however it does do some things that are typically paid-features in common Android apps (i.e. supporting media keys).
    
# Improvement ideas
- [x] ~Make TCP connections a bit more stable~
- [x] ~Add data persistance for TCP servers~
- [x] ~Add Mac support~
- [ ] All standard keyboard keys support
- [ ] Custom key input entry
- [ ] Key sequence support (e.g. CTRL+{key})
- [ ] Mouse control support
- [ ] Ditch Flutter and have native Android support
