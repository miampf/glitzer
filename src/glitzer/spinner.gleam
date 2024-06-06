import gleam/io
import gleam/option.{type Option}

import glearray.{type Array}
import repeatedly.{type Repeater}

import glitzer/codes

/// Contains everything that might get changed during runtime.
pub opaque type State {
  State(
    left_text: String,
    right_text: String,
    progress: Int,
    finished: Bool,
    repeater: Option(Repeater(State)),
  )
}

pub opaque type Frames {
  Frames(frames: Array(String))
}

pub opaque type SpinnerStyle {
  SpinnerStyle(
    frames: Frames,
    tick_rate: Int,
    finish_text: String,
    state: State,
  )
}

/// Convert a given list of `String` to `Frames`.
pub fn frames_from_list(frames frames: List(String)) -> Frames {
  Frames(frames: glearray.from_list(frames))
}

/// The default, pulsating spinner.
pub fn default_spinner() -> SpinnerStyle {
  // ansi codes for a "pulsating" spinner
  let frames = [
    "\u{2591}", "\u{2592}", "\u{2593}", "\u{2588}", "\u{2593}", "\u{2592}",
  ]
  SpinnerStyle(
    frames: frames_from_list(frames),
    tick_rate: 100,
    finish_text: "",
    state: State(
      progress: 0,
      left_text: "",
      right_text: "",
      finished: False,
      repeater: option.None,
    ),
  )
}

/// Set the left text of the spinner.
pub fn with_left_text(spinner s: SpinnerStyle, text t: String) -> SpinnerStyle {
  let s = SpinnerStyle(..s, state: State(..s.state, left_text: t))
  case s.state.repeater {
    option.Some(repeater) -> repeatedly.set_state(repeater, s.state)
    option.None -> Nil
  }
  s
}

/// Set the right text of the spinner.
pub fn with_right_text(spinner s: SpinnerStyle, text t: String) -> SpinnerStyle {
  SpinnerStyle(..s, state: State(..s.state, right_text: t))
}

/// Set the spinners tick rate in milliseconds.
pub fn with_tick_rate(spinner s: SpinnerStyle, ms ms: Int) -> SpinnerStyle {
  SpinnerStyle(..s, tick_rate: ms)
}

/// Set the spinners finish text.
pub fn with_finish_text(spinner s: SpinnerStyle, text t: String) -> SpinnerStyle {
  SpinnerStyle(..s, finish_text: t)
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
    repeatedly.call(s.tick_rate, s.state, fn(state, i) {
      let s = SpinnerStyle(..s, state: state)
      tick_by(s, i)
      |> print_spinner
      state
    })
  SpinnerStyle(..s, state: State(..s.state, repeater: option.Some(repeater)))
}

/// Finish a spinner. If it was countinously ticking, the ticking will be
/// stopped. The line will be cleared and the finish text will be printed if
/// the spinner had some.
pub fn finish(spinner s: SpinnerStyle) -> SpinnerStyle {
  case s.state.repeater {
    option.Some(repeater) -> repeatedly.stop(repeater)
    option.None -> Nil
  }
  io.println(
    codes.hide_cursor_code
    <> codes.clear_line_code
    <> codes.return_line_start_code
    <> s.finish_text,
  )
  SpinnerStyle(..s, state: State(..s.state, finished: True))
}

pub fn print_spinner(spinner s: SpinnerStyle) -> Nil {
  io.print(
    codes.hide_cursor_code
    <> codes.clear_line_code
    <> codes.return_line_start_code
    <> s.state.left_text
    <> get_current_frame_string(s)
    <> s.state.right_text,
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
