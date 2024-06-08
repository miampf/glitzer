/// Spinners! They make the world go round!
///
/// To create a spinner, use [`new_spinner`](#new_spinner), or use one of the
/// templates (named `<TEMPLATENAME>_spinner`) :3.
///
/// Example:
///
/// ```gleam
/// import glitzer/spinner
/// 
/// pub fn main() {
///   let s =
///     spinner.default_spinner()
///     |> spinner.with_left_text("Imma spin >:3 ")
///     |> spinner.with_finish_text("I'm dizzy")
///     |> spinner.spin // this will continuously spin your spinner
/// 
///     // do some stuff
///     
///     // update the text
///     spinner.with_left_text(s, "Now imma spin some more :] ")
/// 
///     spinner.finish(s) // clear the line and print the finish text
/// }
/// ```
import gleam/function
import gleam/io
import gleam/option.{type Option}

import gleam_community/ansi
import gleam_community/colour
import glearray.{type Array}
import repeatedly.{type Repeater}

import glitzer/codes

/// Contains everything that might get changed during runtime.
pub opaque type State {
  State(
    frames: Frames,
    frame_transform: fn(String) -> String,
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
  SpinnerStyle(tick_rate: Int, finish_text: String, state: State)
}

/// Convert a given list of `String` to `Frames`.
pub fn frames_from_list(frames frames: List(String)) -> Frames {
  Frames(frames: glearray.from_list(frames))
}

/// Create a new spinner from `Frames` with a 100ms tick rate.
pub fn new_spinner(frames f: Frames) -> SpinnerStyle {
  SpinnerStyle(
    tick_rate: 100,
    finish_text: "",
    state: State(
      frames: f,
      frame_transform: function.identity,
      progress: 0,
      left_text: "",
      right_text: "",
      finished: False,
      repeater: option.None,
    ),
  )
}

// SECTION: spinner presets

/// The default spinner.
pub fn default_spinner() -> SpinnerStyle {
  let frames = ["|", "/", "-", "\\"]
  new_spinner(frames_from_list(frames))
}

/// A spinner with a bar that goes up and down.
pub fn bar_up_down_spinner() -> SpinnerStyle {
  let frames = [
    "\u{2581}", "\u{2582}", "\u{2583}", "\u{2584}", "\u{2585}", "\u{2586}",
    "\u{2587}", "\u{2588}", "\u{2587}", "\u{2586}", "\u{2585}", "\u{2584}",
    "\u{2583}", "\u{2582}",
  ]
  new_spinner(frames_from_list(frames))
}

/// A spinner that pulsates.
pub fn pulsating_spinner() -> SpinnerStyle {
  let frames = [
    "\u{2591}", "\u{2592}", "\u{2593}", "\u{2588}", "\u{2593}", "\u{2592}",
  ]
  new_spinner(frames_from_list(frames))
}

/// A spinner that goes from left to right and back.
pub fn bar_left_right_spinner() -> SpinnerStyle {
  let frames = [
    "\u{258f}", "\u{258e}", "\u{258d}", "\u{258c}", "\u{258b}", "\u{258a}",
    "\u{2589}", "\u{2588}", "\u{2589}", "\u{258a}", "\u{258b}", "\u{258c}",
    "\u{258d}", "\u{258e}",
  ]
  new_spinner(frames_from_list(frames))
}

/// A spinner that actually spins.
pub fn spinning_spinner() -> SpinnerStyle {
  let frames = [
    "\u{28fe}", "\u{28f7}", "\u{28ef}", "\u{28df}", "\u{287f}", "\u{28bf}",
    "\u{28fb}", "\u{28fd}",
  ]
  new_spinner(frames_from_list(frames))
}

/// A very colorful spinner with the colors from the progress pride flag :3
/// Note that this spinner has a tick rate of 200 instead of 100 to not flash
/// to fast.
pub fn prideful_spinner() -> SpinnerStyle {
  let assert Ok(black) = colour.from_rgb255(0, 0, 0)
  let assert Ok(brown) = colour.from_rgb255(97, 57, 21)
  let assert Ok(blue) = colour.from_rgb255(116, 215, 238)
  let assert Ok(pink) = colour.from_rgb255(255, 175, 200)
  let assert Ok(white) = colour.from_rgb255(255, 255, 255)
  let assert Ok(violet) = colour.from_rgb255(115, 41, 130)
  let assert Ok(indigo) = colour.from_rgb255(36, 64, 142)
  let assert Ok(green) = colour.from_rgb255(0, 128, 38)
  let assert Ok(yellow) = colour.from_rgb255(255, 237, 0)
  let assert Ok(orange) = colour.from_rgb255(255, 140, 0)
  let assert Ok(red) = colour.from_rgb255(228, 3, 3)

  let frames = [
    ansi.color("\u{2591}", black),
    ansi.color("\u{2592}", brown),
    ansi.color("\u{2593}", blue),
    ansi.color("\u{2588}", pink),
    ansi.color("\u{2593}", white),
    ansi.color("\u{2592}", violet),
    ansi.color("\u{2591}", indigo),
    ansi.color("\u{2592}", green),
    ansi.color("\u{2593}", yellow),
    ansi.color("\u{2588}", orange),
    ansi.color("\u{2593}", red),
  ]

  new_spinner(frames_from_list(frames))
  |> with_tick_rate(200)
}

// ENDSECTION: spinner presets

/// Set the left text of the spinner.
pub fn with_left_text(spinner s: SpinnerStyle, text t: String) -> SpinnerStyle {
  let s = SpinnerStyle(..s, state: State(..s.state, left_text: t))
  case s.state.repeater {
    option.Some(repeater) -> repeatedly.set_state(repeater, s.state)
    option.None -> Nil
  }
  s
}

/// Set the frames of the spinner. Useful if you want to update the frames of
/// an already running spinner.
pub fn with_frames(spinner s: SpinnerStyle, frames f: Frames) -> SpinnerStyle {
  let s = SpinnerStyle(..s, state: State(..s.state, frames: f))
  case s.state.repeater {
    option.Some(repeater) -> repeatedly.set_state(repeater, s.state)
    option.None -> Nil
  }
  s
}

/// Set a transformation function that will be applied for each frame. This can
/// be every function with the signature `fn(String) -> String`.
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
/// import glitzer/spinner
/// import gleam_community/ansi
///
/// fn example() {
///   let s =
///     spinner.default_spinner()
///     |> spinner.with_frame_transform(ansi.pink) // make all frames pink
///     |> spinner.spin
///
///   // do some cool stuff
///
///   // update the spinner color and the spinner frames
///   spinner.with_frame_transform(s, ansi.green)
///   |> spinner.with_frames(spinner.frames_from_list(["a", "s", "d", "f"]))
///
///   // do some other stuff
///   
///   spinner.finish(s)
/// }
/// ```
/// </details>
pub fn with_frame_transform(
  spinner s: SpinnerStyle,
  transform fun: fn(String) -> String,
) {
  let s = SpinnerStyle(..s, state: State(..s.state, frame_transform: fun))
  case s.state.repeater {
    option.Some(repeater) -> repeatedly.set_state(repeater, s.state)
    option.None -> Nil
  }
  s
}

/// Set the right text of the spinner.
pub fn with_right_text(spinner s: SpinnerStyle, text t: String) -> SpinnerStyle {
  let s = SpinnerStyle(..s, state: State(..s.state, right_text: t))
  case s.state.repeater {
    option.Some(repeater) -> repeatedly.set_state(repeater, s.state)
    option.None -> Nil
  }
  s
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
  let s =
    SpinnerStyle(..s, state: State(..s.state, progress: s.state.progress + 1))
  case s.state.repeater {
    option.Some(repeater) -> repeatedly.set_state(repeater, s.state)
    option.None -> Nil
  }
  s
}

/// Progress the spinner by `i`.
pub fn tick_by(spinner s: SpinnerStyle, i i: Int) {
  let s =
    SpinnerStyle(..s, state: State(..s.state, progress: s.state.progress + i))
  case s.state.repeater {
    option.Some(repeater) -> repeatedly.set_state(repeater, s.state)
    option.None -> Nil
  }
  s
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
///   |> spinner.spin
/// }
/// ```
///
/// </details>
pub fn spin(spinner s: SpinnerStyle) -> SpinnerStyle {
  let repeater =
    repeatedly.call(s.tick_rate, s.state, fn(state, _) {
      let s = SpinnerStyle(..s, state: state)
      tick(s)
      |> print_spinner
      state
    })
  SpinnerStyle(..s, state: State(..s.state, repeater: option.Some(repeater)))
  // starts the spinner. tbh I don't exactly know why this is needed
  |> tick
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

/// Print the spinner. This is useful if you need/want manual control over your
/// spinner ticks and prints.
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
      s.state.frames.frames,
      s.state.progress % glearray.length(s.state.frames.frames),
    )
  {
    Ok(f) -> s.state.frame_transform(f)
    Error(_) -> ""
  }
}
