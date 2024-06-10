import gleam/iterator
import glitzer/multi
import glitzer/spinner

pub fn main() {
  let _multi =
    multi.new_same_line()
    |> multi.insert_spinner_inline("s1", spinner.pulsating_spinner())
    |> multi.insert_spinner_inline(
      "s2",
      spinner.with_tick_rate(spinner.default_spinner(), 500),
    )
    |> multi.run_line

  iterator.range(0, 1_000_000_000)
  |> iterator.run
}
