local test = require("santoku.test")

local err = require("santoku.error")
local assert = err.assert
local pcall = err.pcall

local validate = require("santoku.validate")
local eq = validate.isequal

local tbl = require("santoku.table")
local teq = tbl.equals

local sqlite = require("santoku.sqlite.db")
local sql = require("santoku.sqlite")
local migrate = require("santoku.sqlite.migrate")

test("applies all migrations and records them", function ()
  local db = sql(sqlite.open_memory())
  migrate(db, {
    ["0.0.1"] = "create table a (x);",
    ["0.0.2"] = "create table b (y);",
  })
  db.exec("insert into a (x) values (1)")
  db.exec("insert into b (y) values (2)")
  local names = db.all("select filename from migrations order by id", true)()
  assert(teq(names, { { filename = "0.0.1" }, { filename = "0.0.2" } }))
end)

test("does not re-apply migrations", function ()
  local db = sql(sqlite.open_memory())
  local m = {
    ["0.0.1"] = "create table c (n integer); insert into c (n) values (1);",
  }
  migrate(db, m)
  migrate(db, m)
  assert(eq(db.getter("select count(*) from c")(), 1))
end)

test("applies only new migrations on later runs", function ()
  local db = sql(sqlite.open_memory())
  local first = "create table d (n integer); insert into d (n) values (1);"
  migrate(db, { ["0.0.1"] = first })
  migrate(db, {
    ["0.0.1"] = first,
    ["0.0.2"] = "insert into d (n) values (2);",
  })
  assert(teq(db.all("select n from d order by n", true)(), { { n = 1 }, { n = 2 } }))
end)

test("applies migrations in numeric version order", function ()
  local db = sql(sqlite.open_memory())
  local function ins (v)
    return "create table if not exists log (seq integer primary key, name text);" ..
      " insert into log (name) values ('" .. v .. "');"
  end
  migrate(db, {
    ["0.0.2"] = ins("0.0.2"),
    ["0.0.10"] = ins("0.0.10"),
    ["0.1.0"] = ins("0.1.0"),
  })
  assert(teq(db.all("select name from log order by seq", true)(), {
    { name = "0.0.2" }, { name = "0.0.10" }, { name = "0.1.0" },
  }))
end)

test("rolls back the whole batch on a failing migration", function ()
  local db = sql(sqlite.open_memory())
  local ok = pcall(migrate, db, {
    ["0.0.1"] = "create table e (n);",
    ["0.0.2"] = "this is not valid sql;",
  })
  assert(eq(ok, false))
  assert(eq(pcall(function () db.exec("insert into e (n) values (1)") end), false))
end)

test("rejects non-table migrations", function ()
  local db = sql(sqlite.open_memory())
  assert(eq(pcall(migrate, db, "nope"), false))
end)
