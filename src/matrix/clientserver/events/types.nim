import std/[tables, options]
import ../types

type
  UnsignedData* = object
    age*: int
    redactedBecause*: Event
    transactionId*: string
    inviteRoomState*: seq[StrippedState]

  RoomEvent* = object of Event
    eventId*: string
    sender*: string
    originServerTs*: int
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

  StrippedState* = object
    content*: EventContent
    stateKey*: string
    `type`*: string
    sender*: string

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
