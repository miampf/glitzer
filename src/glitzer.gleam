import gleam/iterator
import glitzer/multi
import glitzer/progress
import glitzer/spinner

pub fn main() {
  let multi =
    multi.new_same_line()
    |> multi.insert_spinner_inline("s1", spinner.pulsating_spinner())
    |> multi.insert_spinner_inline(
      "s2",
      spinner.with_tick_rate(spinner.default_spinner(), 500),
    )
    |> multi.insert_progress_inline("p1", progress.fancy_slim_bar())
    |> multi.insert_progress_inline(
      "p2",
      progress.with_length(progress.fancy_thick_bar(), 10),
    )
    |> multi.run_line

  iterator.range(0, 100_000_000)
  |> iterator.run

  multi.tick_by_inline(multi, "p1", 50)
  |> multi.tick_by_inline("p2", 10)

  iterator.range(0, 100_000_000)
  |> iterator.run
}
