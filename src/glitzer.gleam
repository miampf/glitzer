import gleam/iterator
import glitzer/spinner

pub fn main() {
  let s =
    spinner.default_spinner()
    |> spinner.with_left_text("Imma spin >:3 ")
    |> spinner.with_finish_text("I'm dizzy :(")
    |> spinner.spin
  // this will continuously spin your spinner

  iterator.range(0, 100_000_000)
  |> iterator.run

  // update the text
  spinner.with_left_text(s, "Now imma spin some more :] ")
  |> spinner.with_frame_transform(fn(s) { "<" <> s <> ">" })
  |> spinner.spin

  iterator.range(0, 100_000_000)
  |> iterator.run

  spinner.finish(s)
  // clear the line and print the finish text
}
