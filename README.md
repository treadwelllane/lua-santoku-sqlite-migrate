# santoku-sqlite-migrate

Versioned, idempotent SQL migrations for a santoku-sqlite database handle. A single
callable module: pass it a DB handle and a table of named migrations, and it applies the
ones that have not run yet, in version order, inside one transaction.

This README is a usage guide, not an API reference. The test is the spec:
`test/spec/santoku/sqlite/migrate.lua` exercises the full surface (ordering, idempotence,
rollback, validation).

## Dependencies

- Base `santoku` (runtime): see [../lua-santoku/README.md](../lua-santoku/README.md).
- `santoku-sqlite` (tests, and to obtain a DB handle): see
  [../lua-santoku-sqlite/README.md](../lua-santoku-sqlite/README.md). The handle's
  `transaction`, `exec`, `getter`, and `inserter` methods are documented there; this module
  does not re-expose them.

## The module

`require("santoku.sqlite.migrate")` returns one function:

    migrate(db, migrations)

- `db`: a santoku-sqlite handle.
- `migrations`: a table mapping a name (string key) to a SQL string (value). Non-table
  values raise.

Behaviour:

- Ensures a `migrations(id integer primary key, filename text not null)` bookkeeping table.
- Sorts keys with a version-aware comparator: numeric runs compare as numbers, so
  `0.0.2` < `0.0.10` < `0.1.0`, not lexically.
- Skips any name already recorded in `migrations`, applies the rest, records each as it runs.
- Runs the whole batch in one `db.transaction`: a failure rolls back every change from that
  call, including the bookkeeping rows.

Re-running with the same table is a no-op; adding a new key applies only the new entry.

## Usage

```lua
local sql = require("santoku.sqlite")
local sqlite = require("santoku.sqlite.db")
local migrate = require("santoku.sqlite.migrate")

local db = sql(sqlite.open_memory())

migrate(db, {
  ["0.0.1"] = "create table a (x);",
  ["0.0.2"] = "create table b (y);",
})

-- both applied and recorded; a second migrate(db, ...) with the same keys does nothing
local names = db.all("select filename from migrations order by id", true)()
-- { { filename = "0.0.1" }, { filename = "0.0.2" } }
```

Covers: `test/spec/santoku/sqlite/migrate.lua`.

## Building / testing

This repo uses the `toku` build harness. The spec under `test/spec/santoku/` requires
`santoku-sqlite`; run the suite through `toku` so that dependency is on the path.

## License

MIT License

Copyright 2025 Birch Point SWE

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
