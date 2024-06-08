import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}

import glitzer/progress.{type ProgressStyle}
import glitzer/spinner.{type SpinnerStyle}

pub opaque type StyleWrapper {
  Progress(ProgressStyle)
  Spinner(SpinnerStyle)
}

pub opaque type SameLine {
  SameLine(line: Dict(String, Option(StyleWrapper)))
}

pub fn new_same_line() -> SameLine {
  SameLine(dict.new())
}

pub fn insert_progress_inline(
  line l: SameLine,
  name n: String,
  progress p: ProgressStyle,
) -> SameLine {
  SameLine(dict.insert(l.line, n, Some(Progress(p))))
}

pub fn insert_spinner_inline(
  line l: SameLine,
  name n: String,
  spinner s: SpinnerStyle,
) -> SameLine {
  SameLine(dict.insert(l.line, n, Some(Spinner(s))))
}

pub fn run_spinners_inline(line l: SameLine) -> SameLine {
  let new_line =
    dict.map_values(l.line, fn(_key, value) {
      case value {
        Some(Progress(p)) -> Some(Progress(p))
        Some(Spinner(s)) -> Some(Spinner(spinner.spin(s)))
        None -> None
      }
    })
  SameLine(new_line)
}

pub fn run_spinner_inline(line l: SameLine, name n: String) -> SameLine {
  let new_line =
    dict.update(l.line, n, fn(spinner) {
      case spinner {
        Some(s) -> {
          case s {
            Some(Progress(p)) -> Some(Progress(p))
            Some(Spinner(s)) -> Some(Spinner(spinner.spin(s)))
            None -> None
          }
        }
        option.None -> option.None
      }
    })
  SameLine(new_line)
}

pub fn tick_progress_inline(line l: SameLine, name n: String) -> SameLine {
  let new_line =
    dict.update(l.line, n, fn(progress) {
      case progress {
        Some(p) -> {
          case p {
            Some(Progress(p)) -> Some(Progress(progress.tick(p)))
            Some(Spinner(s)) -> Some(Spinner(s))
            None -> None
          }
        }
        None -> None
      }
    })
  SameLine(new_line)
}

pub opaque type MultiLine {
  MultiLine(lines: List(StyleWrapper))
}
