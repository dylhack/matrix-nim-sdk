import std/parsecfg

const location = "./tests/config.ini"
let config = loadConfig(location)

proc getServer*(): string  =
  return config.getSectionValue("", "homeserver")

proc getUsername*(): string =
  return config.getSectionValue("", "username")

proc getPassword*(): string =
  return config.getSectionValue("", "password")
