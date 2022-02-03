import std/[json, tables, options]

type
  AccountData* = object
    events*: seq[Event]

  Event* = object
    content*: JsonNode
    `type`*: string

  Presence* = object
    events*: seq[Event]

  Rooms* = object
    invite*: Table[string, InvitedRoom]
    join*: Table[string, JoinedRoom]
    knock*: Table[string, KnockedRoom]
    leave*: Table[string, LeftRoom]

  InvitedRoom* = object
    inviteState*: InviteState

  InviteState* = object
    events*: seq[StrippedStateEvent]

  StrippedStateEvent* = object
    content*: JsonNode
    sender*: string
    stateKey*: string
    `type`*: string

  JoinedRoom* = object
    accountData*: AccountData
    ephemeral*: Ephemeral
    state*: State
    summary*: RoomSummary
    timeline*: Timeline
    unreadNotifications*: UnreadNotificationCounts

  Ephemeral* = object
    events*: seq[Event]

  State* = object
    events*: seq[ClientEventWithoutRoomID]

  ClientEventWithoutRoomID* = object
    content*: JsonNode
    eventId*: string
    originServerTs*: int
    sender*: string
    stateKey*: Option[string]
    `type`*: string
    unsigned*: UnsignedData

  UnsignedData* = ref object
    age*: int64
    prevContent*: JsonNode
    redactedBecause*: Option[ClientEventWithoutRoomID]
    transactionId*: string

  RoomSummary* = object
    `m.heroes`*: Option[seq[string]]
    `m.joined_member_count`*: Option[int]
    `m.invited_member_count`*: Option[int]

  Timeline* = object
    events*: seq[ClientEventWithoutRoomID]
    limited*: bool
    prevBatch*: string

  UnreadNotificationCounts* = object
    highlightCount*: int
    notificationCount*: int

  KnockedRoom* = object
    knockState: KnockState

  KnockState* = object
    events*: seq[StrippedStateEvent]

  LeftRoom* = object
    accountData*: AccountData
    state*: State
    timeline*: Timeline

  PresenceState* = enum
    offline = "offline", online = "online", unavailable = "unavailable"

  ToDevice* = object
    events*: seq[Event]

  DeviceLists* = object
    changed*: seq[string]
    left*: seq[string]

  ## Refers to msgtype
  MessageType* = enum
    `m.text` = "m.text",
    `m.emote` = "m.emote",
    `m.notice` = "m.notice",
    `m.image` = "m.image",
    `m.file` = "m.file",
    `m.audio` = "m.audio",
    `m.location` = "m.location",
    `m.video` = "m.video"

  Direction* = enum
    forward = "f", backward = "b"

  ClientEvent* = object
    eventId*: string
    originServerTs*: int64
    roomId*: string
    sender*: string
    stateKey*: Option[string]
    unsigned*: Option[UnsignedData]
