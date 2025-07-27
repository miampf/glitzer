import gleam/yielder
import gleeunit
import glitzer/multi

import birdie
import pprint

import glitzer/progress
import glitzer/spinner

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

pub fn progress_with_fill_head_finished_test() {
  progress.new_bar()
  |> progress.with_fill_finished(progress.char_from_string("#"))
  |> pprint.format
  |> birdie.snap(title: "Test progress.with_fill_head_finished")
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

pub fn progress_map_yielder_test() {
  let bar = progress.new_bar()
  yielder.empty()
  |> progress.map_yielder(bar, fn(_, _) { progress.print_bar(bar) })
  |> pprint.format
  |> birdie.snap(title: "Test progress.map_yielder")
}

pub fn progress_map2_yielder_test() {
  let bar = progress.new_bar()
  let y1 = yielder.empty()
  let y2 = yielder.empty()
  progress.map2_yielder(y1, y2, bar, fn(_, _, _) { progress.print_bar(bar) })
  |> pprint.format
  |> birdie.snap(title: "Test progress.map2_yielder")
}

pub fn spinner_frames_from_list_test() {
  spinner.frames_from_list(["a", "b", "c"])
  |> pprint.format
  |> birdie.snap(title: "Test spinner.frames_from_list")
}

pub fn spinner_default_spinner_test() {
  spinner.default_spinner()
  |> pprint.format
  |> birdie.snap(title: "Test spinner.default_spinner")
}

pub fn spinner_bar_up_down_spinner_test() {
  spinner.bar_up_down_spinner()
  |> pprint.format
  |> birdie.snap(title: "Test spinner.bar_up_down_spinner")
}

pub fn spinner_pulsating_spinner_test() {
  spinner.pulsating_spinner()
  |> pprint.format
  |> birdie.snap(title: "Test spinner.pulsating_spinner")
}

pub fn spinner_bar_left_right_spinner_test() {
  spinner.bar_left_right_spinner()
  |> pprint.format
  |> birdie.snap(title: "Test spinner.bar_left_right_spinner")
}

pub fn spinner_spinning_spinner_test() {
  spinner.spinning_spinner()
  |> pprint.format
  |> birdie.snap(title: "Test spinner.spinning_spinner")
}

pub fn spinner_prideful_spinner_test() {
  spinner.prideful_spinner()
  |> pprint.format
  |> birdie.snap(title: "Test spinner.prideful_spinner")
}

pub fn spinner_with_left_text_test() {
  spinner.default_spinner()
  |> spinner.with_left_text("asdf")
  |> pprint.format
  |> birdie.snap(title: "Test spinner.with_left_text")
}

pub fn spinner_with_right_text_test() {
  spinner.default_spinner()
  |> spinner.with_right_text("asdf")
  |> pprint.format
  |> birdie.snap(title: "Test spinner.with_right_text")
}

pub fn spinner_with_tick_rate_test() {
  spinner.default_spinner()
  |> spinner.with_tick_rate(10)
  |> pprint.format
  |> birdie.snap(title: "Test spinner.with_tick_rate")
}

pub fn spinner_with_finish_text_test() {
  spinner.default_spinner()
  |> spinner.with_finish_text("asdf")
  |> pprint.format
  |> birdie.snap(title: "Test spinner.with_finish_text")
}

pub fn spinner_with_frames_test() {
  spinner.default_spinner()
  |> spinner.with_frames(spinner.frames_from_list(["a", "s", "d", "f"]))
  |> pprint.format
  |> birdie.snap(title: "Test spinner.with_frames")
}

pub fn spinner_with_frame_transform_test() {
  spinner.default_spinner()
  |> spinner.with_frame_transform(fn(_) { "asdf" })
  |> pprint.format
  |> birdie.snap(title: "Test spinner.with_frame_transform")
}

pub fn spinner_tick_test() {
  spinner.default_spinner()
  |> spinner.tick()
  |> pprint.format
  |> birdie.snap(title: "Test spinner.tick")
}

pub fn spinner_tick_by_test() {
  spinner.default_spinner()
  |> spinner.tick_by(10)
  |> pprint.format
  |> birdie.snap(title: "Test spinner.tick_by")
}

pub fn multi_new_same_line_test() {
  multi.new_same_line()
  |> pprint.format
  |> birdie.snap(title: "Test multi.new_same_line")
}

pub fn multi_insert_spinner_progress_test() {
  multi.new_same_line()
  |> multi.insert_spinner_inline("s1", spinner.default_spinner())
  |> multi.insert_progress_inline("p1", progress.default_bar())
  |> pprint.format
  |> birdie.snap(
    title: "Test multi.insert_spinner_inline and multi.insert_progress_inline",
  )
}
