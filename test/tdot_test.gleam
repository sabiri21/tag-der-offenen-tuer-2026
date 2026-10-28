import gleeunit
import gleeunit/should
import json_handlers

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn challenge_count_label_test() {
  json_handlers.challenge_count_label(7)
  |> should.equal("7 gelöst")
}
