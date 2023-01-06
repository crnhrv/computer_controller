### Windows Controller

A basic client (cross platform built with Flutter, with a focus on Android app), and server (Rust), which allow a user to send keyboard events over TCP to control a Windows machine.

Currently the functionality is (very) limited to a few keys that I personally use for controlling playback in MPV from my phone.

This is primarily a personal development project & I don't expect anyone to use this. There are better options available for this kind of thing, however it does do some things that are typically paid-features in common Android apps (i.e. supporting media keys).

# Future improvement ideas

    1. TCP connection isn't very robust
    2. All typical keyboard key support/custom keys
    3. Key sequence support (e.g. CTRL+{key})
    4. Mouse control support
	5. Client doesn't actually store server addresses currently
    6. Ditch Flutter and have native Android support
