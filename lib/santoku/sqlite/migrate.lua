local arr = require("santoku.array")
local amap = arr.map
local asort = arr.sort

local str = require("santoku.string")
local scmp = str.compare

local iter = require("santoku.iter")
local collect = iter.collect
local filter = iter.filter
local ivals = iter.ivals
local keys = iter.keys

return function (db, migrations)

  assert(type(migrations) == "table", "migrations must be a table")

  local sorted = amap(asort(collect(keys(migrations)), scmp), function (name)
    return { name = name, data = migrations[name] }
  end)

  db.transaction(function ()

    db.exec([[
      create table if not exists migrations (
        id integer primary key,
        filename text not null
      );
    ]])

    local get_migration = db.getter("select id from migrations where filename = ?", "id")
    local add_migration = db.inserter("insert into migrations (filename) values (?)")

    for rec in filter(function (rec)
      return not get_migration(rec.name)
    end, ivals(sorted)) do
      db.exec(rec.data)
      add_migration(rec.name)
    end

  end)

end
