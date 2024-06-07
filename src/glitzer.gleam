import glitzer/spinner

pub fn main() {
  let s =
    spinner.default_spinner()
    |> spinner.with_left_text("Imma spin >:3 ")
    |> spinner.with_finish_text("I'm dizzy")
    |> spinner.spin
  // this will continuously spin your spinner

  // do some stuff
  do(0)

  // update the text
  spinner.with_left_text(s, "Now imma spin some more :]")
  do(0)

  spinner.finish(s)
  // clear the line and print the finish text
}

fn do(i) {
  case i < 5_000_000_000 {
    True -> do(i + 1)
    False -> Nil
  }
}
