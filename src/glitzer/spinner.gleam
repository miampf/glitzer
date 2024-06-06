import gleam/io
import gleam/option.{type Option}

import glearray.{type Array}
import repeatedly.{type Repeater}

import glitzer/codes

pub opaque type State {
  State(progress: Int, finished: Bool, repeater: Option(Repeater(SpinnerStyle)))
}

pub opaque type Frames {
  Frames(frames: Array(String))
}

pub opaque type SpinnerStyle {
  SpinnerStyle(
    frames: Frames,
    left_text: String,
    right_text: String,
    tick_rate: Int,
    state: State,
  )
}

/// Convert a given list of `String` to `Frames`.
pub fn frames_from_list(frames frames: List(String)) -> Frames {
  Frames(frames: glearray.from_list(frames))
}

/// The default, pulsating spinner.
pub fn default_spinner() -> SpinnerStyle {
  // block codes for a "pulsating" spinner
  let frames = [
    "\u{2591}", "\u{2592}", "\u{2593}", "\u{2588}", "\u{2593}", "\u{2592}",
  ]
  SpinnerStyle(
    frames: frames_from_list(frames),
    left_text: "",
    right_text: "",
    tick_rate: 100,
    state: State(progress: 0, finished: False, repeater: option.None),
  )
}

/// Set the left text of the spinner.
pub fn with_left_text(spinner s: SpinnerStyle, text t: String) -> SpinnerStyle {
  SpinnerStyle(..s, left_text: t)
}

/// Set the right text of the spinner.
pub fn with_right_text(spinner s: SpinnerStyle, text t: String) -> SpinnerStyle {
  SpinnerStyle(..s, right_text: t)
}

/// Set the spinners tick rate in milliseconds.
pub fn with_tick_rate(spinner s: SpinnerStyle, ms ms: Int) -> SpinnerStyle {
  SpinnerStyle(..s, tick_rate: ms)
}

/// Progress the spinner by one.
pub fn tick(spinner s: SpinnerStyle) -> SpinnerStyle {
  SpinnerStyle(..s, state: State(..s.state, progress: s.state.progress + 1))
}

/// Progress the spinner by `i`.
pub fn tick_by(spinner s: SpinnerStyle, i i: Int) {
  SpinnerStyle(..s, state: State(..s.state, progress: s.state.progress + i))
}

/// Continuously tick and print the spinner. Note that this **does not** update
/// the tick value of your spinner reference!
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
/// import glitzer/spinner
///
/// fn example() {
///   spinner.default_spinner()
///   |> spinner.continuous_tick_print
/// }
/// ```
///
/// </details>
pub fn continuous_tick_print(spinner s: SpinnerStyle) -> SpinnerStyle {
  let repeater =
    repeatedly.call(s.tick_rate, s, fn(_, i) {
      tick_by(s, i)
      |> print_spinner
    })
  SpinnerStyle(..s, state: State(..s.state, repeater: option.Some(repeater)))
}

pub fn print_spinner(spinner s: SpinnerStyle) -> Nil {
  io.print(
    codes.hide_cursor_code
    <> codes.clear_line_code
    <> codes.return_line_start_code
    <> s.left_text
    <> get_current_frame_string(s)
    <> s.right_text,
  )
}

fn get_current_frame_string(s: SpinnerStyle) -> String {
  case
    glearray.get(
      s.frames.frames,
      s.state.progress % glearray.length(s.frames.frames),
    )
  {
    Ok(f) -> f
    Error(_) -> ""
  }
}
