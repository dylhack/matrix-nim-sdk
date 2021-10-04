import std/options

# Shared types
type AuthData* = object of RootObj
  `type`*: string
  session*: Option[string]

