import std/tables
import ../sharedtypes

type
  PresenceState* = enum
    offline = "offline", online = "online", unavailable = "unavailable"

  RoomSummary* = object
    `m.heroes`*: seq[string]
    `m.joinedMemberCount`*: int
    `m.invited_member_count`*: int

  State* = object
    events*: seq[StateEvent]

  UnreadNotificationCounts* = object
    highlightCount*: int
    notificationCount*: int

  Timeline* = object
    events*: seq[RoomEvent]
    limited*: bool
    prevBatch*: string

  JoinedRoom* = object
    summary*: RoomSummary
    state*: State
    timeline*: Timeline
    ephemeral*: Ephemeral
    accountData*: AccountData
    unreadNotifications*: UnreadNotificationCounts

  InvitedRoom* = object
    events*: seq[StrippedState]

  LeftRoom* = object
    state*: State
    timeline*: Timeline
    accountData*: AccountData

  Rooms* = object
    join*: Table[string, JoinedRoom]
    invite*: Table[string, InvitedRoom]
    leave*: Table[string, LeftRoom]

  EventSequence* = object
    events*: seq[Event]

  Ephemeral* = EventSequence

  AccountData* = EventSequence

  Presence* = EventSequence

  ToDevice* = EventSequence

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
