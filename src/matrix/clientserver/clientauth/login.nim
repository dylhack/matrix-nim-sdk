import std/[httpcore, options]
import jsony
import ../../core
import ../endpoints
when defined(js):
  import std/[asyncjs, jsffi]
else:
  import std/asyncdispatch

type
  UserIdentifier* = object
    idType: string
  IdentityServerInfo* = object
    baseUrl: string
  HomeServerInfo* = object
    baseUrl: string
  DiscoveryInfo* = object
    homeserver: HomeServerInfo
    identityServer: Option[IdentityServerInfo]
  LoginReq* = object
    `type`: string
    user: string
    password: string
    device_id: Option[string]
  LoginRes* = object
    userId*, accessToken*, deviceId*: string
    wellKnown*: Option[DiscoveryInfo]

proc newLoginReq(
  client: MatrixClient,
  username,
  password: string,
  deviceId: Option[string] = none(string)
): PureRequest =
  const typ = "m.login.password"
  let
    target = loginSubmit.build(client.server)
    payload = LoginReq(
      `type`: typ,
      user: username,
      password: password,
      device_id: deviceId
    )
  return PureRequest(
    endpoint: target,
    data: payload.toJson()
  )

proc newLoginRes(res: PureResponse): LoginRes =
  return res.body.fromJson(LoginRes)

proc login*(
  client: AsyncMatrixClient | SyncMatrixClient,
  username,
  password: string,
  deviceId: string = ""
): Future[LoginRes] {.multisync.} =
  let
    device = if len(deviceId) == 0: none(string) else: some(deviceId)
    req = newLoginReq(
      client,
      username = username,
      password = password,
      deviceId = device
    )
    res = await client.request(req)
  return newLoginRes(res)

proc newLogoutReq(
  client: MatrixClient
): PureRequest =
  let
    target = endpoints.logout.build(client.server)
  return PureRequest(endpoint: target, data: "")

proc logout*(
  client: AsyncMatrixClient | SyncMatrixClient
): Future[bool] {.multisync.} =
  let
    req = newLogoutReq(client)
    res = await client.request(req)
  return res.code.is2xx()

proc newLogoutAllReq(client: MatrixClient): PureRequest =
  let
    target = endpoints.logoutAll.build(client.server)
  return PureRequest(endpoint: target, data: "")

proc logoutAll*(
  client: AsyncMatrixClient | SyncMatrixClient
): Future[bool] {.multisync.} =
  let
    req = newLogoutAllReq(client)
    resp = await client.request(req)
  return resp.code.is2xx()
