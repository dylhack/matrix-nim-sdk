import std/httpcore
import pkg/jsony
import ../../core
import ../endpoints
import ../../asyncutils

type
  JoinedRoomsRes* = object
    joinedRooms*: seq[string]

proc newJoinedRoomsRes(res: PureResponse): JoinedRoomsRes =
  return res.body.fromJson(JoinedRoomsRes)

proc joinedRooms*(
  client: MatrixClient,
): Future[JoinedRoomsRes] {.fastsync.} =
  let
    target = joinedRoomsGet.build(client.server)
    req = PureRequest(
      endpoint: target,
      data: ""
    )
    res = await client.request(req)
  return newJoinedRoomsRes(res)
