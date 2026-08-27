local test = require("santoku.test")

local err = require("santoku.error")
local assert = err.assert

local validate = require("santoku.validate")
local eq = validate.isequal

local tbl = require("santoku.table")
local teq = tbl.equals

local sqlite = require("santoku.sqlite.db")
local sql = require("santoku.sqlite")
local migrate = require("santoku.sqlite.migrate")

test("apply migrations in version order and record them", function ()
  local db = sql(sqlite.open_memory())
  migrate(db, {
    ["0.0.1"] = "create table a (x);",
    ["0.0.2"] = "create table b (y);",
  })
  db.exec("insert into a (x) values (1)")
  db.exec("insert into b (y) values (2)")
  local applied = db.all("select filename from migrations order by id", true)()
  assert(teq(applied, { { filename = "0.0.1" }, { filename = "0.0.2" } }))
end)

test("applying twice is a no-op", function ()
  local db = sql(sqlite.open_memory())
  local migrations = {
    ["0.0.1"] = "create table c (n integer); insert into c (n) values (1);",
  }
  migrate(db, migrations)
  migrate(db, migrations)
  assert(eq(db.getter("select count(*) from c")(), 1))
end)

test("only new migrations run on later passes", function ()
  local db = sql(sqlite.open_memory())
  local first = "create table d (n integer); insert into d (n) values (1);"
  migrate(db, { ["0.0.1"] = first })
  migrate(db, {
    ["0.0.1"] = first,
    ["0.0.2"] = "insert into d (n) values (2);",
  })
  assert(teq(db.all("select n from d order by n", true)(), { { n = 1 }, { n = 2 } }))
end)
