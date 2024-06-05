import gleam/iterator
import gleeunit

import birdie
import pprint

import glitzer/progress

pub fn main() {
  gleeunit.main()
}

pub fn progress_char_from_string_success_test() {
  progress.char_from_string("!")
  |> pprint.format
  |> birdie.snap(title: "Test progress.char_from_string (success)")
}

pub fn progress_char_from_string_fail_test() {
  progress.char_from_string("somethinglong")
  |> pprint.format
  |> birdie.snap(title: "Test progress.char_from_string (failure)")
}

pub fn progress_string_from_char_test() {
  progress.char_from_string("#")
  |> progress.string_from_char
  |> birdie.snap(title: "Test progress.string_from_char")
}

pub fn progress_default_bar_test() {
  progress.default_bar()
  |> pprint.format
  |> birdie.snap(title: "Test progress.default_bar")
}

pub fn progress_slim_bar_test() {
  progress.slim_bar()
  |> pprint.format
  |> birdie.snap(title: "Test progress.slim_bar")
}

pub fn progress_fancy_slim_bar_test() {
  progress.fancy_slim_bar()
  |> pprint.format
  |> birdie.snap(title: "Test progress.fancy_slim_bar")
}

pub fn progress_fancy_slim_arrow_bar_test() {
  progress.fancy_slim_arrow_bar()
  |> pprint.format
  |> birdie.snap(title: "Test progress.fancy_slim_arrow_bar")
}

pub fn progress_thick_bar_test() {
  progress.thick_bar()
  |> pprint.format
  |> birdie.snap(title: "Test progress.tick_bar")
}

pub fn progress_fancy_thick_bar_test() {
  progress.fancy_thick_bar()
  |> pprint.format
  |> birdie.snap(title: "Test progress.fancy_thick_bar")
}

pub fn progress_new_bar_test() {
  progress.new_bar()
  |> pprint.format
  |> birdie.snap(title: "Test progress.new_bar")
}

pub fn progress_with_left_text_test() {
  progress.new_bar()
  |> progress.with_left_text("asdf")
  |> pprint.format
  |> birdie.snap(title: "Test progress.with_left_text")
}

pub fn progress_with_right_text_test() {
  progress.new_bar()
  |> progress.with_right_text("asdf")
  |> pprint.format
  |> birdie.snap(title: "Test progress.with_right_text")
}

pub fn progress_with_empty_test() {
  progress.new_bar()
  |> progress.with_empty(progress.char_from_string("#"))
  |> pprint.format
  |> birdie.snap(title: "Test progress.with_empty")
}

pub fn progress_with_fill_test() {
  progress.new_bar()
  |> progress.with_fill(progress.char_from_string("#"))
  |> pprint.format
  |> birdie.snap(title: "Test progress.with_fill")
}

pub fn progress_with_fill_finished_test() {
  progress.new_bar()
  |> progress.with_fill_finished(progress.char_from_string("#"))
  |> pprint.format
  |> birdie.snap(title: "Test progress.with_fill_finished")
}

pub fn progress_with_fill_head_test() {
  progress.new_bar()
  |> progress.with_fill_head(progress.char_from_string("#"))
  |> pprint.format
  |> birdie.snap(title: "Test progress.with_fill_head")
}

pub fn progress_with_length_test() {
  progress.new_bar()
  |> progress.with_length(100)
  |> pprint.format
  |> birdie.snap(title: "Test progress.with_length")
}

pub fn progress_tick_test() {
  progress.new_bar()
  |> progress.tick
  |> pprint.format
  |> birdie.snap(title: "Test progress.tick")
}

pub fn progress_tick_by_test() {
  progress.new_bar()
  |> progress.tick_by(10)
  |> pprint.format
  |> birdie.snap(title: "Test progress.tick_by")
}

pub fn progress_finish_test() {
  progress.new_bar()
  |> progress.with_length(100)
  |> progress.finish
  |> pprint.format
  |> birdie.snap(title: "Test progresss.finish")
}

pub fn progress_map_iterator_test() {
  let bar = progress.new_bar()
  iterator.empty()
  |> progress.map_iterator(bar, fn(_, _) { progress.print_bar(bar) })
  |> pprint.format
  |> birdie.snap(title: "Test progress.map_iterator")
}

pub fn progress_map2_iterator_test() {
  let bar = progress.new_bar()
  let i1 = iterator.empty()
  let i2 = iterator.empty()
  progress.map2_iterator(i1, i2, bar, fn(_, _, _) { progress.print_bar(bar) })
  |> pprint.format
  |> birdie.snap(title: "Test progress.map2_iterator")
}
