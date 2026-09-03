local env = {
  name = "santoku-sqlite-migrate",
  version = "2.0.1-1",
  variable_prefix = "TK_SQLITE_MIGRATE",
  license = "MIT",
  public = true,
  dependencies = {
    "lua == 5.1",
    "santoku >= 2.0.0, < 3.0.0",
  },
  test = {
    dependencies = {
      "santoku-sqlite >= 3.0.0, < 4.0.0",
    },
  },
}

env.homepage = "https://github.com/birchpointswe/lua-" .. env.name
env.tarball = env.name .. "-" .. env.version .. ".tar.gz"
env.download = env.homepage .. "/releases/download/" .. env.version .. "/" .. env.tarball

return { env = env }

