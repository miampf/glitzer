import glitzer/spinner

pub fn main() {
  spinner.default_spinner()
  |> spinner.continuous_tick_print
  do(0)
}

fn do(i) {
  case i < 1_000_000_000_000 {
    True -> do(i + 1)
    False -> Nil
  }
}
