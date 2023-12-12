local err = require("santoku.err")
local gen = require("santoku.gen")
local op = require("santoku.op")
local tup = require("santoku.tuple")
local fs = require("santoku.fs")
local str = require("santoku.string")

local M = {}

M.migrate = function (db, opts)
  return err.pwrap(function (check)

    local files

    if type(opts) == "string" then

      local fp = opts
      files = fs.files(fp):map(check):vec():sort(str.compare):map(function (fp)
        return tup(fs.basename(fp), function ()
          return check(fs.readfile(fp))
        end)
      end)

    elseif type(opts) == "table" then

      local tbl = opts
      files = gen.keys(tbl):vec():sort(str.compare):map(function (fp)
        return tup(fs.basename(fp), function ()
          return opts[fp]
        end)
      end)

    else
      return false, "invalid argument type to migrate: " .. type(opts)
    end

    check(db:begin())

    check(db:exec([[
      create table if not exists migrations (
        id integer primary key,
        filename text not null
      );
    ]]))

    local get_migration = check(db:getter("select id from migrations where filename = ?", "id"))
    local add_migration = check(db:inserter("insert into migrations (filename) values (?)"))

    gen.ivals(files):map(op.call):filter(function (fp)
      return not check(get_migration(fp))
    end):map(function (fp, read)
      return fp, read()
    end):each(function (fp, data)
      check(db:exec(data))
      check(add_migration(fp))
    end)

    check(db:commit())

  end)
end

return M
