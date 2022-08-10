import
  std/httpcore,
  ../../core,
  ../../utils,
  ../endpoints
include ../../utils/jsonyutils


type
  SetDisplayNameReq* = object
    displayname*: string

proc newSetDisplayNameReq(
    client: MatrixClient,
    userId, displayname: string,
  ): PureRequest =
  let
    target = displaynamePut.build(client.server, pathParams = [("userId", userId)])
    payload = SetDisplaynameReq(
      displayname: displayname
    )
  return PureRequest(
    endpoint: target,
    data: toJson(payload)
  )

proc setDisplayName*(
  client: MatrixClient,
  userId, displayname: string
): Future[bool] {.fastsync.} =
  let
    req = newSetDisplayNameReq(
      client,
      userId,
      displayname
    )
    res = await client.request(req)
  return res.code.is2xx()
