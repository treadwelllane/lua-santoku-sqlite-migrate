local env = {

  name = "santoku-sqlite-migrate",
  version = "0.0.12-1",
  variable_prefix = "TK_SQLITE_MIGRATE",
  license = "MIT",
  public = true,

  dependencies = {
    "lua >= 5.1",
    "santoku >= 0.0.189-1",
    "santoku-fs >= 0.0.28-1",
    "santoku-sqlite >= 0.0.11-1",
  },

  test = {
    dependencies = {
      "luacov >= 0.15.0-1",
    }
  },

}

env.homepage = "https://github.com/treadwelllane/lua-" .. env.name
env.tarball = env.name .. "-" .. env.version .. ".tar.gz"
env.download = env.homepage .. "/releases/download/" .. env.version .. "/" .. env.tarball

return {
  type = "lib",
  env = env,
}

