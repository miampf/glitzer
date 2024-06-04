import gleam/io
import gleam/string
import gleam/string_builder.{type StringBuilder}

import glitzer/codes

/// A `String` with only one character.
pub opaque type Char {
  Char(char: String)
}

/// Create a `Char` from a `String`. Returns a `Char` with the given string if
/// the strings length is equal to one and a `Char` of "#" otherwise.
///
/// <details>
/// <summary>Example:<summary>
///
/// ```gleam
/// import glitzer/progress
///
/// fn example() {
///   let char = progress.char_from_string("A")
/// }
/// ```
pub fn char_from_string(from in: String) -> Char {
  let len = string.length(in)

  case len {
    1 -> Char(in)
    _ -> Char("#")
  }
}

pub fn string_from_char(from in: Char) -> String {
  in.char
}

pub opaque type State {
  State(progress: Int)
}

/// The style of a progress bar.
pub opaque type ProgressStyle {
  ProgressStyle(
    left: String,
    right: String,
    empty: Char,
    fill: Char,
    length: Int,
    state: State,
  )
}

/// Create and return a default style for a progress bar.
pub fn default_bar() -> ProgressStyle {
  ProgressStyle(
    left: "[",
    right: "]",
    empty: Char(" "),
    fill: Char("#"),
    length: 100,
    state: State(progress: 0),
  )
}

/// Create a new (completely empty) progress bar.
///
/// <details>
/// <summary>Example:<summary>
///
/// ```gleam
/// import glitzer/progress
///
/// fn example() {
///   let bar = 
///     progress.new_bar()
///     |> progress.with_length(50)
///     |> progress.with_left_text("Progress: ")
///     |> progress.with_fill(progress.char_from_string("+"))
/// }
/// ```
pub fn new_bar() -> ProgressStyle {
  ProgressStyle(
    left: "",
    right: "",
    empty: Char(" "),
    fill: Char(" "),
    length: 0,
    state: State(progress: 0),
  )
}

/// Add left text to a progress bar.
pub fn with_left_text(
  bar bar: ProgressStyle,
  left text: String,
) -> ProgressStyle {
  ProgressStyle(..bar, left: text)
}

/// Add right text to a progress bar.
pub fn with_right_text(
  bar bar: ProgressStyle,
  right text: String,
) -> ProgressStyle {
  ProgressStyle(..bar, right: text)
}

/// Add a character to a progress bar that is used to represent the
/// "background" of the bar.
pub fn with_empty(bar bar: ProgressStyle, empty char: Char) -> ProgressStyle {
  ProgressStyle(..bar, empty: char)
}

/// Add a character to a progress bar that is used to fill the bar on each
/// tick.
pub fn with_fill(bar bar: ProgressStyle, fill char: Char) -> ProgressStyle {
  ProgressStyle(..bar, fill: char)
}

/// Add length to a progress bar.
pub fn with_length(bar bar: ProgressStyle, length len: Int) -> ProgressStyle {
  ProgressStyle(..bar, length: len)
}

/// Increase the progress of the bar by one.
pub fn tick(bar bar: ProgressStyle) -> ProgressStyle {
  ProgressStyle(..bar, state: State(progress: bar.state.progress + 1))
}

/// Completely fill the progress bar.
pub fn finish(bar bar: ProgressStyle) -> ProgressStyle {
  ProgressStyle(..bar, state: State(progress: bar.length + 1))
}

/// Print the progress bar to stderr.
///
/// <details>
/// <summary>Example:<summary>
///
/// ```gleam
/// import glitzer/progress
///
/// fn example() {
///   let bar = progress.default_bar()
///
///   run_example(bar, 0)
/// }
///
/// fn run_example(bar, count) {
///   case count < 100 {
///     True -> {
///       let bar = progress.tick(bar)
///       // do some awesome stuff :3
///       progress.print_bar(bar)
///       run_example(bar, count + 1)
///     }
///     False -> Nil
///   }
/// }
/// ```
pub fn print_bar(bar bar: ProgressStyle) {
  let fill =
    build_progress_fill(string_builder.new(), bar, bar.state.progress, 0)
    |> string_builder.to_string

  io.print_error(
    codes.clear_line_code
    <> codes.return_line_start_code
    <> bar.left
    <> fill
    <> bar.right,
  )
}

fn build_progress_fill(
  fill: StringBuilder,
  bar: ProgressStyle,
  left_nonempty: Int,
  count: Int,
) -> StringBuilder {
  let fill = case left_nonempty > 0 {
    True -> string_builder.append(fill, bar.fill.char)
    False -> string_builder.append(fill, bar.empty.char)
  }

  case bar.length > count {
    True -> build_progress_fill(fill, bar, left_nonempty - 1, count + 1)
    False -> fill
  }
}
