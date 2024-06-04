import gleam/iterator

import glitzer/progress

@external(erlang, "glitzer_ffi", "sleep")
@external(javascript, "./glitzer_ffi.mjs", "sleep")
pub fn sleep(ms: Int) -> a

pub fn main() {
  let bar = progress.default_bar()

  iterator.range(0, 100)
  |> iterator.map(fn(_) {
    let bar = progress.tick(bar)
    progress.print_bar(bar)
    sleep(1000)
  })
  |> iterator.run
}
