import context.{type Context}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import sqlight
import wisp.{type Request, type Response}

pub fn challenge_count_label(count: Int) -> String {
  int.to_string(count) <> " gelöst"
}

pub type User {
  User(id: Int, name: String)
}

pub fn user_to_json(user: User) -> json.Json {
  json.object([
    #("id", json.int(user.id)),
    #("name", json.string(user.name)),
  ])
}

pub fn all_users() -> List(User) {
  [User(1, "Alice"), User(2, "Bob")]
}

pub fn list_users() -> Response {
  all_users()
  |> json.array(user_to_json)
  |> json.to_string
  |> wisp.json_response(200)
}

pub fn get_user(id: String) -> Response {
  let found = {
    use id <- result.try(int.parse(id))
    list.find(all_users(), fn(u) { u.id == id })
  }

  case found {
    Ok(user) ->
      user |> user_to_json |> json.to_string |> wisp.json_response(200)
    Error(_) -> error_json("User not found", 404)
  }
}

pub fn create_user(req: Request) -> Response {
  use body <- wisp.require_json(req)

  let decoder = {
    use name <- decode.field("name", decode.string)
    decode.success(name)
  }

  case decode.run(body, decoder) {
    Ok(name) ->
      User(3, name)
      |> user_to_json
      |> json.to_string
      |> wisp.json_response(201)
    Error(_) -> error_json("Body must be {\"name\": \"...\"}", 422)
  }
}

pub fn error_json(message: String, status: Int) -> Response {
  json.object([#("error", json.string(message))])
  |> json.to_string
  |> wisp.json_response(status)
}

pub fn search_person(req: Request, ctx: Context) -> Response {
  let query =
    wisp.get_query(req)
    |> list.key_find("name")
    |> result.unwrap("")

  let decoder = {
    use name <- decode.field(0, decode.string)
    use image <- decode.field(1, decode.string)
    decode.success(#(name, image))
  }

  // VULNERABLE: user input concatenated directly into SQL.
  // Do not do this outside a sandboxed teaching demo.
  let sql =
    "select name, image from people where name like '%" <> query <> "%' limit 1"

  let rows = sqlight.query(sql, on: ctx.db, with: [], expecting: decoder)

  case rows {
    Ok([#(name, image), ..]) ->
      json.object([
        #("name", json.string(name)),
        #("image", json.string("/static/avatars/" <> image)),
      ])
      |> json.to_string
      |> wisp.json_response(200)
    Ok([]) -> error_json("Not found", 404)
    Error(_) -> error_json("Database error", 500)
  }
}

/// not susceptible against SQL Injections
pub fn search_person_safe(req: Request, ctx: Context) -> Response {
  let query =
    wisp.get_query(req)
    |> list.key_find("name")
    |> result.unwrap("")

  let decoder = {
    use name <- decode.field(0, decode.string)
    use image <- decode.field(1, decode.string)
    decode.success(#(name, image))
  }

  let rows =
    sqlight.query(
      "select name, image from people where name like ? limit 1",
      on: ctx.db,
      with: [sqlight.text("%" <> query <> "%")],
      expecting: decoder,
    )

  case rows {
    Ok([#(name, image), ..]) ->
      json.object([
        #("name", json.string(name)),
        #("image", json.string("/static/avatars/" <> image)),
      ])
      |> json.to_string
      |> wisp.json_response(200)
    Ok([]) -> error_json("Not found", 404)
    Error(_) -> error_json("Database error", 500)
  }
}

pub fn submit_flag(req: Request, ctx: Context) -> Response {
  use body <- wisp.require_json(req)

  let decoder = {
    use challenge_id <- decode.field("challenge_id", decode.string)
    use flag <- decode.field("flag", decode.string)
    decode.success(#(challenge_id, flag))
  }

  case decode.run(body, decoder) {
    Ok(#(challenge_id, flag)) -> check_and_record(challenge_id, flag, ctx)
    Error(_) ->
      error_json(
        "Body must be {\"challenge_id\": \"...\", \"flag\": \"...\"}",
        422,
      )
  }
}

fn check_and_record(
  challenge_id: String,
  flag: String,
  ctx: Context,
) -> Response {
  let decoder = {
    use flag <- decode.field(0, decode.string)
    decode.success(flag)
  }

  let result =
    sqlight.query(
      "select flag from challenges where id = ?",
      on: ctx.db,
      with: [sqlight.text(challenge_id)],
      expecting: decoder,
    )

  case result {
    Ok([correct_flag, ..]) if correct_flag == flag -> {
      let empty_decoder = decode.success(Nil)
      let _ =
        sqlight.query(
          "update challenges set solve_count = solve_count + 1 where id = ?",
          on: ctx.db,
          with: [sqlight.text(challenge_id)],
          expecting: empty_decoder,
        )
      json.object([#("correct", json.bool(True))])
      |> json.to_string
      |> wisp.json_response(200)
    }
    Ok(_) ->
      json.object([#("correct", json.bool(False))])
      |> json.to_string
      |> wisp.json_response(200)
    Error(_) -> error_json("Database error", 500)
  }
}
