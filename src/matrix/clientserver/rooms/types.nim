type
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