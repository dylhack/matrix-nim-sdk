import pkg/jsony
import ../../core
import ../endpoints
import ../../asyncutils
import types

type
  RoomEventReq* = object
    eventId*: string
    roomId*: string
  RoomEventRes* = object
    content*: string
    `type`*: string
  SendRoomEventReq* = object
    eventType*: string
    roomId*: string
    stateKey*: string
    event*: RoomEvent
  SendRoomEventRes* = object
    eventId*: string

proc newRoomEventReq(
    client: MatrixClient,
    eventId, roomId: string
  ): PureRequest =
  let target = roomEventGet.build(client.server, urlParams = [("eventId", eventId), ("roomId", roomId)])
  return PureRequest(endpoint: target)

proc newSendRoomEventReq(
    client: MatrixClient,
    eventType, roomId, stateKey: string,
    event: RoomEvent
  ): PureRequest =
  let
    target = roomEventGet.build(client.server, urlParams = [("eventType", eventType), ("roomId", roomId), ("stateKey", stateKey)])
    payload = event.toJson()
  return PureRequest(
    endpoint: target,
    data: payload
  )

proc newRoomEventRes(res: PureResponse): RoomEventRes =
  return res.body.fromJson(RoomEventRes)

proc newSendRoomEventRes(res: PureResponse): SendRoomEventRes =
  return res.body.fromJson(SendRoomEventRes)

proc getRoomEvent*(
    client: MatrixClient,
    eventId, roomId: string
  ): Future[RoomEventRes] {.fastsync.} =
  let
    req = newRoomEventReq(
      client,
      eventId,
      roomId
    )
    res = await client.request(req)
  return newRoomEventRes(res)

proc sendRoomEvent*(
    client: MatrixClient,
    eventType, roomId: string,
    event: RoomEvent,
    stateKey: string = ""
  ): Future[SendRoomEventRes] {.fastsync.} =
  let
    req = newSendRoomEventReq(
      client,
      eventType,
      roomId,
      stateKey,
      event
    )
    res = await client.request(req)
  return newSendRoomEventRes(res)
