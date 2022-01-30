import std/json

type
  Event* = object of RootObj
    content*: JsonNode
    `type`*: string