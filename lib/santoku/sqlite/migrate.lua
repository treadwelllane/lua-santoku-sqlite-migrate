local arr = require("santoku.array")
local amap = arr.map
local asort = arr.sort

local tbl = require("santoku.table")
local tkeys = tbl.keys

local str = require("santoku.string")
local scmp = str.compare

return function (db, migrations)

  assert(type(migrations) == "table", "migrations must be a table")

  local sorted = amap(asort(tkeys(migrations), scmp), function (name)
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

    for i = 1, #sorted do
      local rec = sorted[i]
      if not get_migration(rec.name) then
        db.exec(rec.data)
        add_migration(rec.name)
      end
    end

  end)

end
