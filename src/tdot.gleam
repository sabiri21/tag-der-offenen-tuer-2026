import context.{type Context, Context}
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/http.{Get, Post}
import gleam/list
import gleam/string
import json_handlers
import mist
import simplifile
import sqlight
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  let assert Ok(priv) = wisp.priv_directory("tdot")
  let assert Ok(db) = sqlight.open("file:htldb.sqlite")
  let assert Ok(_) = context.fill_db(db)
  let ctx = Context(db)

  let assert Ok(_) =
    wisp_mist.handler(handle_request(_, priv, ctx), secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}

fn handle_request(req: Request, priv: String, ctx: Context) -> Response {
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use <- wisp.serve_static(req, under: "/static", from: priv <> "/static")

  case req.method, wisp.path_segments(req) {
    Get, [] -> serve_index(priv, ctx)
    Get, ["htldb"] -> serve_html(priv, "htldb.html")
    Get, ["notenportal"] -> serve_html(priv, "notenportal.html")
    Get, ["wartungsseite"] -> serve_html(priv, "wartungsseite.html")

    Get, ["api", "htldb"] -> json_handlers.search_person(req, ctx)
    Post, ["api", "flag"] -> json_handlers.submit_flag(req, ctx)

    _, _ -> wisp.not_found()
  }
}

fn serve_index(priv: String, ctx: Context) -> Response {
  let html = simplifile.read(priv <> "/static/index.html")

  case html {
    Ok(doc) -> {
      let counts = [
        #("__SQL_INJECTION_SOLVE_COUNT__", "sql_injection"),
        #("__HIDDEN_IN_SOURCE_SOLVE_COUNT__", "hidden_in_source"),
        #("__SESSION_COOKIES_SOLVE_COUNT__", "session_cookies"),
      ]

      let rendered =
        list.fold(counts, doc, fn(acc, item) {
          let #(placeholder, challenge_id) = item
          let count = challenge_solve_count(ctx.db, challenge_id)
          string.replace(
            acc,
            placeholder,
            json_handlers.challenge_count_label(count),
          )
        })

      wisp.html_response(rendered, 200)
    }
    Error(_) -> wisp.internal_server_error()
  }
}

fn serve_html(priv: String, file: String) -> Response {
  case simplifile.read(priv <> "/static/" <> file) {
    Ok(html) -> wisp.html_response(html, 200)
    Error(_) -> wisp.internal_server_error()
  }
}

fn challenge_solve_count(db: sqlight.Connection, challenge_id: String) -> Int {
  let decoder = {
    use count <- decode.field(0, decode.int)
    decode.success(count)
  }

  let rows =
    sqlight.query(
      "select solve_count from challenges where id = ?",
      on: db,
      with: [sqlight.text(challenge_id)],
      expecting: decoder,
    )

  case rows {
    Ok([count, ..]) -> count
    _ -> 0
  }
}
