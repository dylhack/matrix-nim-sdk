import
  std/httpcore,
  ../../core,
  ../../utils,
  ../endpoints
include ../../utils/jsonyutils


type
  RoomAliasReq* = object
    roomAlias*: string
    roomId*: string

proc newRoomAliasReq(
    client: MatrixClient,
    roomAlias, roomId: string,
  ): PureRequest =
  let
    target = roomAliasPut.build(client.server, pathParams = [("roomAlias", roomAlias)])
    payload = RoomAliasReq(roomId: roomId)
  return PureRequest(
    endpoint: target,
    data: toJson(payload)
  )

proc createRoomAlias*(
  client: MatrixClient,
  roomAlias, roomId: string
): Future[bool] {.fastsync.} =
  let
    req = newRoomAliasReq(
      client,
      roomAlias,
      roomId
    )
    res = await client.request(req)
  return res.code.is2xx()
