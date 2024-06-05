import gleam/int
import gleam/iterator

import glitzer/progress

@external(erlang, "glitzer_ffi", "sleep")
@external(javascript, "./glitzer_ffi.mjs", "sleep")
pub fn sleep(ms: Int) -> a

pub fn main() {
  let bar =
    progress.fancy_thick_bar()
    |> progress.with_length(10)

  do_something(bar, 0)
  do_something_else()
}

fn do_something(bar, count) {
  case count < 10 {
    True -> {
      let bar = progress.tick(bar)
      progress.print_bar(bar)
      sleep(100)
      do_something(bar, count + 1)
    }
    False -> Nil
  }
}

fn do_something_else() {
  let bar =
    progress.fancy_slim_arrow_bar()
    |> progress.with_length(10)

  iterator.range(0, 10)
  |> progress.each_iterator(bar, fn(bar, i) {
    progress.with_left_text(bar, int.to_string(i) <> " ")
    |> progress.print_bar
    sleep(100)
  })
}
