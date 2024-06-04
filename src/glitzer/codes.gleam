/// Print this code to clear the whole screen.
pub const clear_screen_code = "\u{001b}[2J"

/// Print this code to clear the current line.
pub const clear_line_code = "\u{001b}[2K"

/// Print this code to return the cursor to the "home" position.
pub const return_home_code = "\u{001b}[H"

/// Print this code to return to the start of the line
pub const return_line_start_code = "\r"

pub const hide_cursor_code = "\u{001b}[?25l"
