type
  Preset* = enum
    privateChat = "private_chat", publicChat = "public_chat", trustedPrivateChat = "trusted_private_chat"

  Visibility* = enum
    public = "public", private = "private"

  Invite3pid* = object
    idServer*: string
    idAccessToken*: string
    medium*: string
    address*: string

  StateEvent* = object
    `type`*: string
    stateKey*: string
    content*: string