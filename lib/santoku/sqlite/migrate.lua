local arr = require("santoku.array")
local amap = arr.map
local asort = arr.sort

local fs = require("santoku.fs")
local basename = fs.basename
local readfile = fs.readfile
local files = fs.files

local str = require("santoku.string")
local scmp = str.compare

local iter = require("santoku.iter")
local collect = iter.collect
local filter = iter.filter
local ivals = iter.ivals
local keys = iter.keys

return function (db, opts)

  local migrations

  if type(opts) == "string" then

    migrations = amap(asort(collect(files(opts, true)), scmp), function (fp)
      return { name = basename(fp), data = function () return readfile(fp) end }
    end)

  elseif type(opts) == "table" then

    migrations = amap(asort(collect(keys(opts)), scmp), function (fp)
      return { name = basename(fp), data = function () return opts[fp] end }
    end)

  else
    error("invalid argument type to migrate: ", type(opts))
  end

  db.begin()

  db.exec([[
    create table if not exists migrations (
      id integer primary key,
      filename text not null
    );
  ]])

  local get_migration = db.getter("select id from migrations where filename = ?", "id")
  local add_migration = db.inserter("insert into migrations (filename) values (?)")

  for rec in filter(function (fp)
    return not get_migration(fp)
  end, ivals(migrations)) do
    db.exec(rec.data())
    add_migration(rec.name)
  end

  db.commit()

end
