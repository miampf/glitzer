pub opaque type State {
  State(progress: Int)
}

pub opaque type SpinnerStyle {
  SpinnerStyle(frames: List(String), tick_rate: Int, state: State)
}
