import gleam/iterator
import glitzer/spinner

pub fn main() {
  let s =
    spinner.default_spinner()
    |> spinner.with_left_text("Imma spin >:3 ")
    |> spinner.with_finish_text("I'm dizzy :(")
    |> spinner.spin
  // this will continuously spin your spinner

  // do some stuff
  iterator.range(0, 1_000_000)
  |> iterator.run

  // update the text
  spinner.with_left_text(s, "Now imma spin some more :] ")
  spinner.with_frames(s, spinner.frames_from_list(["a", "b", "c"]))
  iterator.range(0, 1_000_000)
  |> iterator.run

  spinner.finish(s)
  // clear the line and print the finish text
}
