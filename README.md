# Santoku SQLite Migrate

Database migration management for SQLite databases.

## Module Reference

### `santoku.sqlite.migrate`

| Function | Arguments | Returns | Description |
|----------|-----------|---------|-------------|
| `migrate` | `db, opts` | `nil` | Applies migrations to database |

**Parameters:**
- `db`: Database connection with `transaction`, `exec`, `getter`, `inserter` methods
- `opts`: Migration source - directory path (string) or migration table (table)

**Behavior:**
- Creates `migrations` table if not exists
- Processes migrations alphabetically by filename
- Skips already-applied migrations
- Runs within database transaction
- Throws error on failure

**Migration tracking table:**
```sql
CREATE TABLE migrations (
  id INTEGER PRIMARY KEY,
  filename TEXT NOT NULL
)
```

**Directory structure:**
- Files processed alphabetically by name
- Each file contains SQL statements to execute
- Example: `001_users.sql`, `002_posts.sql`, `003_indexes.sql`

**Table structure:**
- Keys: migration filenames (processed alphabetically)
- Values: SQL statements to execute or functions returning SQL
- Example: `{["001_users.sql"] = "CREATE TABLE ...", ["002_posts.sql"] = function() return "ALTER TABLE ..." end}`

### Directory-based usage
```lua
local sqlite = require("lsqlite3")
local sql = require("santoku.sqlite")
local migrate = require("santoku.sqlite.migrate")

local db = sql(sqlite.open("app.db"))
migrate(db, "./migrations")
```

### Table-based usage
```lua
local sqlite = require("lsqlite3")
local sql = require("santoku.sqlite")
local migrate = require("santoku.sqlite.migrate")

local db = sql(sqlite.open("app.db"))
migrate(db, {
  ["001_init.sql"] = "CREATE TABLE users (id INTEGER PRIMARY KEY)",
  ["002_posts.sql"] = "CREATE TABLE posts (id INTEGER PRIMARY KEY)"
})
```

## License

MIT License

Copyright 2025 Matthew Brooks

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