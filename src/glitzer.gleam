import glitzer/progress

@external(erlang, "glitzer_ffi", "sleep")
@external(javascript, "./glitzer_ffi.mjs", "sleep")
pub fn sleep(ms: Int) -> a

pub fn main() {
  let bar =
    progress.fancy_slim_bar()
    |> progress.with_fill_head(progress.char_from_string(">"))
    |> progress.with_length(10)

  do_something(bar, 0)
}

fn do_something(bar, count) {
  case count < 10 {
    True -> {
      let bar = case count > 5 {
        True -> progress.finish(bar)
        False -> progress.tick(bar)
      }
      progress.print_bar(bar)
      sleep(100)
      do_something(bar, count + 1)
    }
    False -> Nil
  }
}
