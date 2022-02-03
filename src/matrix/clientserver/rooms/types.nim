import std/json

type
  Preset* = enum
    privateChat = "private_chat", publicChat = "public_chat", trustedPrivateChat = "trusted_private_chat"

  Visibility* = enum
    public = "public", private = "private"

  StateEvent* = object
    content*: JsonNode
    stateKey*: string
    `type`*: string

  Invite3pid* = object
    address*: string
    idAccessToken*: string
    idServer*: string
    medium*: string

  Membership* = enum
    invite = "invite", join = "join", knock = "knock", leave = "leave", ban = "ban"

  Signed* = object
    mxId*: string
    signatures*: string
    token*: string

  Invite* = object
    displayName*: string
    signed*: Signed


