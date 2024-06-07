import gleam/int
import gleam/iterator

import glitzer/progress
import glitzer/spinner

@external(erlang, "example_ffi", "sleep")
@external(javascript, "./example_ffi.mjs", "sleep")
pub fn sleep(ms: Int) -> a

pub fn main() {
  let bar =
    progress.thick_bar()
    |> progress.with_length(100)

  do_something(bar, 0)
  do_something_else()
  do_cool_shit_with_2_it()
}

fn do_something(bar, count) {
  case count < 100 {
    True -> {
      let bar = progress.tick(bar)
      progress.print_bar(bar)
      sleep(30)
      do_something(bar, count + 1)
    }
    False -> Nil
  }
}

fn do_something_else() {
  let s =
    spinner.spinning_spinner()
    |> spinner.with_left_text("Imma spin >:3 ")
    |> spinner.with_finish_text("I'm dizzy :(")
    |> spinner.spin

  sleep(3000)

  spinner.finish(s)
}

fn do_cool_shit_with_2_it() {
  let bar =
    progress.fancy_slim_arrow_bar()
    |> progress.with_length(100)
  let i1 = iterator.range(0, 100)
  let i2 = iterator.range(100, 200)
  progress.map2_iterator(i1, i2, bar, fn(bar, e1, e2) {
    progress.with_left_text(bar, int.to_string(e1) <> " ")
    |> progress.with_right_text(" " <> int.to_string(e2))
    |> progress.print_bar
    sleep(50)
  })
  |> iterator.run
}
