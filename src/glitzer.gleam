import glitzer/progress

@external(erlang, "glitzer_ffi", "sleep")
@external(javascript, "./glitzer_ffi.mjs", "sleep")
pub fn sleep(ms: Int) -> a

pub fn main() {
  let bar = progress.default_bar()

  do_something(bar, 0)
}

fn do_something(bar, count) {
  case count < 100 {
    True -> {
      let bar = progress.tick(bar)
      progress.print_bar(bar)
      sleep(1000)
      do_something(bar, count + 1)
    }
    False -> Nil
  }
}
