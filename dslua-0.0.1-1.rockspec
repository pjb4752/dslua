package = "dslua"
version = "0.0.1-1"
source = {
  url = "https://github.com/pjb4752/dslua/archive/v0.0.1.tar.gz",
  dir = "dslua-0.0.1"
}
description = {
  summary = "lua collections",
  detailed = [[
    lua collections and enumerators
  ]],
  homepage = "https://github.com/pjb4752/dslua",
  license = ""
}
dependencies = {
  "lua >= 5.1",
}
build = {
  type = "builtin",
  modules = {
    ["dslua.array"] = "dslua/array.lua",
    ["dslua.enum"] = "dslua/enum.lua"
    ["dslua.map"] = "dslua/map.lua",
  }
}
