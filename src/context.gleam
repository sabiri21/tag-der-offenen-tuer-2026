import sqlight

pub type Context {
  Context(db: sqlight.Connection)
}

pub fn create_db_tables(db: sqlight.Connection) -> Result(Nil, sqlight.Error) {
  let assert Ok(_) =
    sqlight.exec(
      "create table if not exists people (
        id integer primary key autoincrement,
        name text not null,
        image text not null
       );
       create table if not exists challenges (
        id text primary key,
        flag text not null,
        solve_count integer default 0 
       );",
      on: db,
    )
}

pub fn fill_db(db: sqlight.Connection) -> Result(Nil, sqlight.Error) {
  let assert Ok(_) = create_db_tables(db)
  let assert Ok(_) =
    sqlight.exec(
      "insert or replace into people (name, image) values
            ('Gerald Zottl', 'zottl.jpg'),
            ('Günter Ebermann', 'ebermann.jpg');

        insert or replace into challenges (id, flag) values
            ('sql_injection', 'HTL{SQL_INJECTION}'),
            ('hidden_in_source', 'HTL{v3rst3ckt_1m_qu3llt3xt}'),
            ('session_cookies', 'HTL{c00k13s_s1nd_k31n_z4un}');
        ",
      on: db,
    )
}
