import gleam/io
import gleam/option.{type Option}

import glearray.{type Array}
import repeatedly.{type Repeater}

import glitzer/codes

pub opaque type State {
  State(progress: Int, finished: Bool, repeater: Option(Repeater(Nil)))
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

pub fn frames_from_list(frames frames: List(String)) -> Frames {
  Frames(frames: glearray.from_list(frames))
}

pub fn default_spinner() -> SpinnerStyle {
  // block codes for a "pulsating" spinner
  let frames = ["\u{2591}", "\u{2592}", "\u{2593}", "\u{2588}"]
  SpinnerStyle(
    frames: frames_from_list(frames),
    left_text: "",
    right_text: "",
    tick_rate: 100,
    state: State(progress: 0, finished: False, repeater: option.None),
  )
}

pub fn with_left_text(spinner s: SpinnerStyle, text t: String) -> SpinnerStyle {
  SpinnerStyle(..s, left_text: t)
}

pub fn with_right_text(spinner s: SpinnerStyle, text t: String) -> SpinnerStyle {
  SpinnerStyle(..s, right_text: t)
}

pub fn with_tick_rate(spinner s: SpinnerStyle, ms ms: Int) -> SpinnerStyle {
  SpinnerStyle(..s, tick_rate: ms)
}

pub fn tick(spinner s: SpinnerStyle) -> SpinnerStyle {
  SpinnerStyle(..s, state: State(..s.state, progress: s.state.progress + 1))
}

pub fn tick_by(spinner s: SpinnerStyle, i i: Int) {
  SpinnerStyle(..s, state: State(..s.state, progress: s.state.progress + i))
}

pub fn continuous_tick_print(spinner s: SpinnerStyle) -> SpinnerStyle {
  let repeater =
    repeatedly.call(s.tick_rate, Nil, fn(_, i) {
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
