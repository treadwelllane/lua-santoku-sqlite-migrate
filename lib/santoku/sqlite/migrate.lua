local arr = require("santoku.array")
local str = require("santoku.string")
local amap = arr.map
local asort = arr.sort

local tbl = require("santoku.table")
local tkeys = tbl.keys

local sbyte = str.byte

local function isdigit (s, i)
  local c = sbyte(s, i)
  return c and c >= 48 and c <= 57
end

local function vlt (a, b)
  local ai, bi = 1, 1
  local an, bn = #a, #b
  while ai <= an and bi <= bn do
    if isdigit(a, ai) and isdigit(b, bi) then
      local ae, be = ai, bi
      while isdigit(a, ae + 1) do ae = ae + 1 end
      while isdigit(b, be + 1) do be = be + 1 end
      local av = tonumber(a:sub(ai, ae))
      local bv = tonumber(b:sub(bi, be))
      if av ~= bv then return av < bv end
      ai, bi = ae + 1, be + 1
    else
      local ac, bc = sbyte(a, ai), sbyte(b, bi)
      if ac ~= bc then return ac < bc end
      ai, bi = ai + 1, bi + 1
    end
  end
  return an < bn
end

return function (db, migrations)

  assert(type(migrations) == "table", "migrations must be a table")

  local sorted = amap(asort(tkeys(migrations), vlt), function (name)
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
