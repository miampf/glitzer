import glitzer/progress

@external(erlang, "glitzer_ffi", "sleep")
@external(javascript, "./glitzer_ffi.mjs", "sleep")
pub fn sleep(ms: Int) -> a

pub fn main() {
  let bar =
    progress.default_bar()
    |> progress.with_fill_finished(progress.char_from_string("-"))

  do_something(bar, 0)
}

fn do_something(bar, count) {
  case count < 100 {
    True -> {
      let bar = case count > 50 {
        True -> progress.finish(bar)
        False -> progress.tick(bar)
      }
      progress.print_bar(bar)
      sleep(15)
      do_something(bar, count + 1)
    }
    False -> Nil
  }
}
