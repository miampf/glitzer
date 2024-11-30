import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/yielder

import repeatedly.{type Repeater}

import glitzer/codes
import glitzer/progress.{type ProgressStyle}
import glitzer/spinner.{type SpinnerStyle}

pub opaque type StyleWrapper {
  Progress(ProgressStyle)
  Spinner(SpinnerStyle)
}

pub opaque type LineState {
  LineState(line: List(#(String, StyleWrapper)))
}

pub opaque type SameLine {
  // Dict of a name, the character offset and the kind of style
  // that should be printed.
  SameLine(
    refresh_rate: Int,
    repeater: Option(Repeater(LineState)),
    state: LineState,
  )
}

/// Create a new `SameLine` that can print multiple spinners/progress bars on
/// the same line.
pub fn new_same_line() -> SameLine {
  SameLine(state: LineState(line: []), refresh_rate: 10, repeater: None)
}

/// Insert a `ProgressStyle` at the end of a given `SameLine`.
pub fn insert_progress_inline(
  line l: SameLine,
  name n: String,
  progress p: ProgressStyle,
) -> SameLine {
  SameLine(
    ..l,
    state: LineState(
      line: list.append(l.state.line, [
        #(n, Progress(progress.with_newline_on_finished(p, False))),
      ]),
    ),
  )
}

/// Insert a `SpinnerStyle` at the end of a given `SameLine`.
pub fn insert_spinner_inline(
  line l: SameLine,
  name n: String,
  spinner s: SpinnerStyle,
) -> SameLine {
  SameLine(
    ..l,
    state: LineState(line: list.append(l.state.line, [#(n, Spinner(s))])),
  )
}

/// Run the line. This will print the whole line every `line.refresh_rate`
/// milliseconds. It will also automatically tick all inline spinners with
/// regard to their tick rate.
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
///  let multi =
///    multi.new_same_line()
///    |> multi.insert_spinner_inline("s1", spinner.pulsating_spinner())
///    |> multi.insert_spinner_inline(
///      "s2",
///      spinner.with_tick_rate(spinner.default_spinner(), 500),
///    )
///    |> multi.run_line
/// ```
/// </details>
pub fn run_line(line l: SameLine) -> SameLine {
  let repeater =
    repeatedly.call(l.refresh_rate, l.state, fn(state, i) {
      // reset the current line 
      io.print(
        codes.hide_cursor_code
        <> codes.clear_line_code
        <> codes.return_line_start_code,
      )
      let new_line =
        // tick all spinners in the line
        yielder.from_list(state.line)
        |> yielder.map(fn(el) {
          let #(name, value) = el
          let value = case value {
            Progress(p) -> Progress(p)
            Spinner(s) -> {
              // how much time passed?
              let time_gone_by = i * l.refresh_rate
              // how many times should the spinner have been ticked?
              let spin_count =
                result.unwrap(int.floor_divide(time_gone_by, s.tick_rate), 0)
              // how much do we have to tick now?
              let left_to_tick = spin_count - s.state.progress
              Spinner(spinner.tick_by(s, left_to_tick))
            }
          }
          #(name, value)
        })
        |> yielder.to_list
      // print the new line 
      yielder.from_list(new_line)
      |> yielder.each(fn(el) {
        let #(_, value) = el
        case value {
          Progress(p) -> print_bar_inline(p)
          Spinner(s) -> print_spinner_inline(s)
        }
      })
      LineState(line: new_line)
    })
  SameLine(..l, repeater: Some(repeater))
}

fn print_bar_inline(p: ProgressStyle) {
  io.print_error(progress.get_raw_bar(p) <> " ")
}

fn print_spinner_inline(s: SpinnerStyle) {
  io.print_error(
    s.state.left_text
    <> spinner.get_current_frame_string(s)
    <> s.state.right_text
    <> " ",
  )
}

/// Tick a spinner or progress bar with the given name by 1. Does nothing if
/// the spinner/progress bar doesn't exist.
pub fn tick_inline(line l: SameLine, name n: String) -> SameLine {
  let value = list.key_find(l.state.line, n)
  let new_state = case value {
    Ok(value) -> {
      case value {
        Progress(p) ->
          LineState(line: list.key_set(
            l.state.line,
            n,
            Progress(progress.tick(p)),
          ))
        Spinner(s) ->
          LineState(line: list.key_set(
            l.state.line,
            n,
            Spinner(spinner.tick(s)),
          ))
      }
    }
    Error(_) -> l.state
  }
  case l.repeater {
    Some(r) -> repeatedly.set_state(r, new_state)
    None -> Nil
  }
  SameLine(..l, state: new_state)
}

/// Tick a spinner or progress bar with the given name by `i`. Does nothing if
/// the spinner/progress bar doesn't exist.
pub fn tick_by_inline(line l: SameLine, name n: String, i i: Int) -> SameLine {
  let value = list.key_find(l.state.line, n)
  let new_state = case value {
    Ok(value) -> {
      case value {
        Progress(p) ->
          LineState(line: list.key_set(
            l.state.line,
            n,
            Progress(progress.tick_by(p, i)),
          ))
        Spinner(s) ->
          LineState(line: list.key_set(
            l.state.line,
            n,
            Spinner(spinner.tick_by(s, i)),
          ))
      }
    }
    Error(_) -> l.state
  }
  case l.repeater {
    Some(r) -> repeatedly.set_state(r, new_state)
    None -> Nil
  }
  SameLine(..l, state: new_state)
}

pub opaque type MultiLineWrapper {
  Style(StyleWrapper)
  Line(SameLine)
}

pub opaque type MultiLine {
  MultiLine(lines: List(MultiLineWrapper))
}
