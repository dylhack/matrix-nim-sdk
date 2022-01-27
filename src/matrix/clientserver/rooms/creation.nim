import pkg/jsony
import ../../core
import ../endpoints
import ../../asyncutils
import types

type
  CreateRoomReq* = object
    roomAliasName*: string
    name*: string
    topic*: string
    invite*: seq[string]
    invite3pid*: seq[Invite3pid]
    roomVersion*: string
    initialState: seq[StateEvent]
    isDirect*: bool
    visibility*: Visibility
    preset*: Preset
  CreateRoomRes* = object
    roomId*: string

proc newCreateRoomReq(
    client: MatrixClient,
    roomAliasName, name, topic, roomVersion: string,
    invite: seq[string],
    invite3pid: seq[Invite3pid],
    initialState: seq[StateEvent],
    isDirect: bool,
    visibility: Visibility,
    preset: Preset
  ): PureRequest =
  let
    target = roomCreate.build(client.server)
    payload = CreateRoomReq(
      roomAliasName: roomAliasName,
      name: name,
      topic: topic,
      roomVersion: roomVersion,
      invite: invite,
      invite3pid: invite3pid,
      initialState: initialState,
      isDirect: isDirect,
      visibility: visibility,
      preset: preset
    )
  return PureRequest(
    endpoint: target,
    data: toJson(payload)
  )

proc newCreateRoomRes(res: PureResponse): CreateRoomRes =
  return res.body.fromJson(CreateRoomRes)

proc createRoom*(
  client: MatrixClient,
  roomAliasName, name, topic, roomVersion: string = "",
  invite: seq[string] = @[],
  invite3pid: seq[Invite3pid] = @[],
  initialState: seq[StateEvent] = @[],
  isDirect: bool = false,
  visibility: Visibility = Visibility.private,
  preset: Preset = Preset.privateChat
): Future[CreateRoomRes] {.fastsync.} =
  let
    req = newCreateRoomReq(
      client,
      roomAliasName,
      name,
      topic,
      roomVersion,
      invite,
      invite3pid,
      initialState,
      isDirect,
      visibility,
      preset
    )
    res = await client.request(req)
  return newCreateRoomRes(res)
