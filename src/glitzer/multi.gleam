import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

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

pub fn new_same_line() -> SameLine {
  SameLine(state: LineState(line: []), refresh_rate: 10, repeater: None)
}

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
        iterator.from_list(state.line)
        |> iterator.map(fn(el) {
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
        |> iterator.to_list
      // print the new line 
      iterator.from_list(new_line)
      |> iterator.each(fn(el) {
        let #(_, value) = el
        case value {
          Progress(p) -> progress.print_bar(p)
          Spinner(s) -> print_spinner_inline(s)
        }
      })
      LineState(line: new_line)
    })
  SameLine(..l, repeater: Some(repeater))
}

fn print_spinner_inline(s: SpinnerStyle) {
  io.print(
    s.state.left_text
    <> spinner.get_current_frame_string(s)
    <> s.state.right_text
    <> " ",
  )
}

pub opaque type MultiLine {
  MultiLine(lines: List(StyleWrapper))
}
