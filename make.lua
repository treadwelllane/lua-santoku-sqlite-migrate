local env = {

  name = "santoku-sqlite-migrate",
  version = "0.0.9-1",
  variable_prefix = "TK_SQLITE_MIGRATE",
  license = "MIT",
  public = true,

  dependencies = {
    "lua >= 5.1",
    "santoku-fs >= 0.0.25-1",
    "santoku-sqlite >= 0.0.9-1",
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

