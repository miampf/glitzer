import gleam/iterator
import gleam/list

import glitzer/progress.{type ProgressStyle}
import glitzer/spinner.{type SpinnerStyle}

pub opaque type StyleWrapper {
  Progress(ProgressStyle)
  Spinner(SpinnerStyle)
}

pub opaque type SameLine {
  SameLine(line: List(StyleWrapper))
}

pub fn new_same_line() -> SameLine {
  SameLine([])
}

pub fn insert_progress_inline(
  line l: SameLine,
  progress p: ProgressStyle,
) -> SameLine {
  SameLine(list.append(l.line, [Progress(p)]))
}

pub fn insert_spinner_inline(
  line l: SameLine,
  spinner s: SpinnerStyle,
) -> SameLine {
  SameLine(list.append(l.line, [Spinner(s)]))
}

pub fn run_spinners(line l: SameLine) -> SameLine {
  let new_line =
    iterator.from_list(l.line)
    |> iterator.map(fn(el) {
      case el {
        Progress(p) -> Progress(p)
        Spinner(s) -> Spinner(spinner.spin(s))
      }
    })
    |> iterator.to_list
  SameLine(new_line)
}

pub opaque type MultiLine {
  MultiLine(lines: List(StyleWrapper))
}
