import glitzer/spinner

pub fn main() {
  let s =
    spinner.prideful_spinner()
    |> spinner.with_finish_text("Hehe >:3")
    |> spinner.continuous_tick_print
  spinner.with_left_text(s, "He: ")
  do(0)
  spinner.finish(s)
}

fn do(i) {
  case i < 1_000_000_000_000 {
    True -> do(i + 1)
    False -> Nil
  }
}
