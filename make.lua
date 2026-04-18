local env = {
  name = "santoku-sqlite-migrate",
  version = "0.0.21-1",
  variable_prefix = "TK_SQLITE_MIGRATE",
  license = "MIT",
  public = true,
  dependencies = {
    "lua == 5.1",
    "santoku >= 0.0.328-1",
  },
}

env.homepage = "https://github.com/birchpointswe/lua-" .. env.name
env.tarball = env.name .. "-" .. env.version .. ".tar.gz"
env.download = env.homepage .. "/releases/download/" .. env.version .. "/" .. env.tarball

return { env = env }

