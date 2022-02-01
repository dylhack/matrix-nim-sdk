import std/[json, options]

type
  Event* = object of RootObj
    content*: JsonNode
    `type`*: string

  StrippedState* = object
    content*: EventContent
    stateKey*: string
    `type`*: string
    sender*: string

  UnsignedData* = object
    age*: int64
    redactedBecause*: Event
    transactionId*: string
    inviteRoomState*: seq[StrippedState]

  RoomEvent* = object of Event
    eventId*: string
    sender*: string
    originServerTs*: int64
    unsigned*: UnsignedData

  Membership* = enum
    invite = "invite", join = "join", knock = "knock", leave = "leave", ban = "ban"

  Signed* = object
    mxId*: string
    signatures*: string
    token*: string

  Invite* = object
    displayName*: string
    signed*: Signed

  EventContent* = object
    avatarUrl*: string
    displayname*: Option[string]
    membership*: Membership
    isDirect*: bool
    thirdPartyInvite*: Invite
    unsigned*: UnsignedData

  StateEvent* = object of RoomEvent
    stateKey*: string
    prevContent*: EventContent
