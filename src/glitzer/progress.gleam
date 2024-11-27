/// Lines that go forward like little snakes :333
///
/// To create a new progress bar use [`new_bar`](#new_bar) or one of the
/// premade templates (named `<TEMPLATENAME>_bar`) :)
///
/// Example:
///
/// ```gleam
/// import gleam/int
/// import gleam/yielder
/// 
/// import glitzer/progress
/// 
/// pub fn main() {
///     let bar = 
///         progress.new_bar() 
///         |> progress.with_length(100)
///         |> progress.with_fill(progress.char_from_string("+"))
///         |> progress.with_empty(progress.char_from_string("-"))
///         |> progress.with_left_text("Doing stuff: ")
///     yielder.range(1, 100)
///     |> progress.each_yielder(bar, fn(bar, i) {
///         progress.with_left_text(bar, int.to_string(i) <> " ")
///         |> progress.print_bar
///         // do some other stuff here
///     })
/// }
/// ```
///
/// ```gleam
/// import glitzer/progress
/// 
/// pub fn main() {
///     let bar = progress.fancy_slim_arrow_bar()
///     do_stuff(bar, 0)
/// }
/// 
/// fn do_stuff(bar, count) {
///     case count < 100 {
///        True -> {
///             let bar = progress.tick(bar)
///             progress.print_bar(bar)
///             // some heavy lifting
///             do_stuff(bar, count + 1)
///         }
///        False -> Nil 
///     }
/// }
/// ```
import gleam/io
import gleam/option.{type Option}
import gleam/string
import gleam/string_tree.{type StringTree}
import gleam/yielder.{type Yielder}

import gleam_community/ansi

import glitzer/codes

/// A `String` with only one character.
pub opaque type Char {
  Char(char: String)
}

/// Create a `Char` from a `String`. Returns a `Char` with the given string if
/// the strings length is equal to one and a `Char` of "#" otherwise.
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
/// import glitzer/progress
///
/// fn example() {
///   let char = progress.char_from_string("A")
/// }
/// ```
///
/// </details>
pub fn char_from_string(from in: String) -> Char {
  let len = string.length(in)

  case len {
    1 -> Char(in)
    _ -> Char("#")
  }
}

/// Create a `String` from a given `Char`.
pub fn string_from_char(from in: Char) -> String {
  in.char
}

pub opaque type State {
  State(progress: Int, finished: Bool)
}

/// The style of a progress bar.
pub opaque type ProgressStyle {
  ProgressStyle(
    left: String,
    right: String,
    empty: Char,
    fill: Char,
    fill_finished: Option(Char),
    fill_head: Option(Char),
    fill_head_finished: Option(Char),
    length: Int,
    state: State,
  )
}

// SECTION: progress bar definitions

/// Create and return a default progress bar.
pub fn default_bar() -> ProgressStyle {
  ProgressStyle(
    left: "[",
    right: "]",
    empty: Char(" "),
    fill: Char("#"),
    fill_finished: option.None,
    fill_head_finished: option.None,
    fill_head: option.None,
    length: 100,
    state: State(progress: 0, finished: False),
  )
}

/// Create and return a fancy and slim progress bar (inspired by pip).
pub fn slim_bar() -> ProgressStyle {
  let sym = "\u{2014}"
  ProgressStyle(
    left: "",
    right: "",
    empty: Char(" "),
    fill: Char(sym),
    fill_finished: option.None,
    fill_head: option.None,
    fill_head_finished: option.None,
    length: 100,
    state: State(progress: 0, finished: False),
  )
}

/// Create and return a fancy and slim progress bar (inspired by pip).
pub fn fancy_slim_bar() -> ProgressStyle {
  let sym = "\u{2014}"
  ProgressStyle(
    left: "",
    right: "",
    empty: Char(ansi.blue(sym)),
    fill: Char(ansi.red(sym)),
    fill_finished: option.Some(Char(ansi.green(sym))),
    fill_head: option.None,
    fill_head_finished: option.None,
    length: 100,
    state: State(progress: 0, finished: False),
  )
}

/// Create and return a fancy and slim progress bar with an arrow head.
pub fn fancy_slim_arrow_bar() -> ProgressStyle {
  let sym = "\u{2014}"
  let sym_head = "\u{2192}"
  ProgressStyle(
    left: "",
    right: "",
    empty: Char(ansi.blue(sym)),
    fill: Char(ansi.red(sym)),
    fill_finished: option.Some(Char(ansi.green(sym))),
    fill_head: option.Some(Char(ansi.red(sym_head))),
    fill_head_finished: option.Some(Char(ansi.green(sym_head))),
    length: 100,
    state: State(progress: 0, finished: False),
  )
}

/// Create and return a thick bar.
pub fn thick_bar() -> ProgressStyle {
  let sym = "\u{2588}"
  let empty_sym = "\u{2592}"
  ProgressStyle(
    left: "",
    right: "",
    empty: Char(empty_sym),
    fill: Char(sym),
    fill_finished: option.None,
    fill_head: option.None,
    fill_head_finished: option.None,
    length: 100,
    state: State(progress: 0, finished: False),
  )
}

/// Create and return a fancy thick bar.
pub fn fancy_thick_bar() -> ProgressStyle {
  let sym = "\u{2588}"
  let empty_sym = "\u{2592}"
  ProgressStyle(
    left: "",
    right: "",
    empty: Char(ansi.blue(empty_sym)),
    fill: Char(ansi.red(sym)),
    fill_finished: option.Some(Char(ansi.green(sym))),
    fill_head: option.None,
    fill_head_finished: option.None,
    length: 100,
    state: State(progress: 0, finished: False),
  )
}

// ENDSECTION: progress bar definitions

/// Create a new (completely empty) progress bar.
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
/// import glitzer/progress
///
/// fn example() {
///   let bar = 
///     progress.new_bar()
///     |> progress.with_length(50)
///     |> progress.with_left_text("Progress: ")
///     |> progress.with_fill(progress.char_from_string("+"))
/// }
/// ```
///
/// </details>
pub fn new_bar() -> ProgressStyle {
  ProgressStyle(
    left: "",
    right: "",
    empty: Char(" "),
    fill: Char(" "),
    fill_finished: option.None,
    fill_head: option.None,
    fill_head_finished: option.None,
    length: 0,
    state: State(progress: 0, finished: False),
  )
}

/// Add left text to a progress bar.
pub fn with_left_text(
  bar bar: ProgressStyle,
  left text: String,
) -> ProgressStyle {
  ProgressStyle(..bar, left: text)
}

/// Add right text to a progress bar.
pub fn with_right_text(
  bar bar: ProgressStyle,
  right text: String,
) -> ProgressStyle {
  ProgressStyle(..bar, right: text)
}

/// Add a character to a progress bar that is used to represent the
/// "background" of the bar.
pub fn with_empty(bar bar: ProgressStyle, empty char: Char) -> ProgressStyle {
  ProgressStyle(..bar, empty: char)
}

/// Add a character to a progress bar that is used to fill the bar on each
/// tick.
pub fn with_fill(bar bar: ProgressStyle, fill char: Char) -> ProgressStyle {
  ProgressStyle(..bar, fill: char)
}

/// Add a character that will be used instead of `fill` if the bar is finished.
pub fn with_fill_finished(
  bar bar: ProgressStyle,
  fill char: Char,
) -> ProgressStyle {
  ProgressStyle(..bar, fill_finished: option.Some(char))
}

/// Add a head to the progress bar.
pub fn with_fill_head(bar bar: ProgressStyle, fill char: Char) -> ProgressStyle {
  ProgressStyle(..bar, fill_head: option.Some(char))
}

/// Add a head to the progress bar that will be displayed when the bar
/// finishes.
pub fn with_fill_head_finished(
  bar bar: ProgressStyle,
  fill char: Char,
) -> ProgressStyle {
  ProgressStyle(..bar, fill_head_finished: option.Some(char))
}

/// Add length to a progress bar.
pub fn with_length(bar bar: ProgressStyle, length len: Int) -> ProgressStyle {
  ProgressStyle(..bar, length: len)
}

/// Increase the progress of the bar by one.
pub fn tick(bar bar: ProgressStyle) -> ProgressStyle {
  case bar.state.progress < bar.length + 1 {
    True ->
      ProgressStyle(
        ..bar,
        state: State(..bar.state, progress: bar.state.progress + 1),
      )
    False ->
      ProgressStyle(
        ..bar,
        state: State(finished: True, progress: bar.state.progress + 1),
      )
  }
}

/// Increase the progress of the bar by `i`.
pub fn tick_by(bar bar: ProgressStyle, i i: Int) -> ProgressStyle {
  case i > 0 {
    True -> {
      let bar = tick(bar)
      tick_by(bar, i - 1)
    }
    False -> bar
  }
}

/// Completely fill the progress bar.
pub fn finish(bar bar: ProgressStyle) -> ProgressStyle {
  ProgressStyle(..bar, state: State(finished: True, progress: bar.length + 1))
}

/// Print the progress bar to stderr.
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
/// import glitzer/progress
///
/// fn example() {
///   let bar = progress.default_bar()
///
///   run_example(bar, 0)
/// }
///
/// fn run_example(bar, count) {
///   case count < 100 {
///     True -> {
///       let bar = progress.tick(bar)
///       // do some awesome stuff :3
///       progress.print_bar(bar)
///       run_example(bar, count + 1)
///     }
///     False -> Nil
///   }
/// }
/// ```
///
/// </details>
pub fn print_bar(bar bar: ProgressStyle) {
  let bar =
    ProgressStyle(
      ..bar,
      state: State(..bar.state, finished: bar.state.progress >= bar.length),
    )
  let fill =
    build_progress_fill(string_tree.new(), bar, bar.state.progress + 1, 0)
    |> string_tree.to_string

  let end = case bar.state.finished {
    True -> "\n" <> codes.show_cursor_code
    False -> ""
  }

  io.print_error(
    codes.hide_cursor_code
    <> codes.clear_line_code
    <> codes.return_line_start_code
    <> bar.left
    <> fill
    <> bar.right
    <> end,
  )
}

fn build_progress_fill(
  fill: StringTree,
  bar: ProgressStyle,
  left_nonempty: Int,
  count: Int,
) -> StringTree {
  let fill = case left_nonempty > 0 {
    True -> {
      case left_nonempty == 1 {
        True -> get_finished_head_fill(fill, bar)
        False -> get_finished_fill(fill, bar)
      }
    }
    // fill all thats left with empty characters
    False -> string_tree.append(fill, bar.empty.char)
  }

  case bar.length > count {
    True -> build_progress_fill(fill, bar, left_nonempty - 1, count + 1)
    False -> fill
  }
}

fn get_finished_head_fill(fill: StringTree, bar: ProgressStyle) -> StringTree {
  case bar.state.finished {
    True ->
      // build the finished style
      string_tree.append(
        fill,
        option.unwrap(
          // if head_finished exists
          bar.fill_head_finished,
          option.unwrap(
            // if only a head exist
            bar.fill_head,
            // otherwise, use fill_finished of fill (if fill_finished doesnt exist)
            option.unwrap(bar.fill_finished, bar.fill),
          ),
        ).char,
      )
    // build the unfinished style
    False ->
      string_tree.append(fill, option.unwrap(bar.fill_head, bar.fill).char)
  }
}

fn get_finished_fill(fill: StringTree, bar: ProgressStyle) -> StringTree {
  case bar.state.finished {
    True ->
      // build the finished style
      string_tree.append(fill, option.unwrap(bar.fill_finished, bar.fill).char)
    // build the unfinished style
    False -> string_tree.append(fill, bar.fill.char)
  }
}

/// Map an yielder to a function with a bar that ticks every run of the
/// function.
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
/// import glitzer/progress
///
/// fn example(bar) {
///   yielder.range(0, 100)
///   |> progress.map_yielder(fn(bar, element) {
///     progress.print_bar(bar)
///     // do some heavy calculations here >:)
///   })
/// }
/// ```
///
/// </details>
pub fn map_yielder(
  over y: Yielder(a),
  bar bar: ProgressStyle,
  with fun: fn(ProgressStyle, a) -> b,
) -> Yielder(b) {
  yielder.index(y)
  |> yielder.map(fn(pair) {
    let #(el, i) = pair
    tick_bar_by_i(bar, i)
    |> fun(el)
  })
}

fn tick_bar_by_i(bar, i) -> ProgressStyle {
  case i > 0 {
    True -> tick_bar_by_i(tick(bar), i - 1)
    False -> bar
  }
}

pub fn map2_yielder(
  yielder1 y1: Yielder(a),
  yielder2 y2: Yielder(b),
  bar bar: ProgressStyle,
  with fun: fn(ProgressStyle, a, b) -> c,
) -> Yielder(c) {
  yielder.zip(y1, y2)
  |> yielder.index
  |> yielder.map(fn(pair) {
    let #(pair, i) = pair
    let #(el1, el2) = pair
    tick_bar_by_i(bar, i)
    |> fun(el1, el2)
  })
}

pub fn each_yielder(
  over y: Yielder(a),
  bar bar: ProgressStyle,
  with fun: fn(ProgressStyle, a) -> b,
) -> Nil {
  yielder.index(y)
  |> yielder.each(fn(pair) {
    let #(el, i) = pair
    tick_bar_by_i(bar, i)
    |> fun(el)
  })
}
