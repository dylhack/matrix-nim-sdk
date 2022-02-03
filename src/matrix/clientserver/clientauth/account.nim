## 5.6 Account registration and management
## https://matrix.org/docs/spec/client_server/r0.6.1#account-registration-and-management
import
  std/options,
  ../../core,
  ../endpoints,
  ../../asyncutils,
  types
include ../../jsonyutils


type
  ChangePasswordReq* = object
    new_password*: string
    logout_devices*: bool
    auth: AccountAuth
  DeactivateReq* = object
    id_server*: Option[string]
    auth*: AccountAuth
  RegisterRes* = object
    userId*, accessToken*, deviceId*: string
  RegisterReq* = object of RootObj
    auth*: AuthData
    kind*: string
    password*: string
    device_id*: Option[string]
  RegisterReqName* = object of RegisterReq
    username*: Option[string]
  UsernameAvailableRes* = object
    availability*: bool
  WhoAmIRes* = object
    deviceId*: string
    userId*: string


const
  PASS_AUTH = "m.login.password"
  ID_USER_TYPE = "m.id.user"

proc newRegisterReq(
  client: MatrixClient,
  username: Option[string] = none(string),
  password: string = "",
  deviceId: Option[string] = none(string)
): PureRequest =
  let
    kind = if username.isNone(): "guest" else: "user"
    auth = AuthData(
      `type`: "m.login.dummy",
      session: none(string)
    )
    target = accountRegister.build(client.server, queryParams = [("kind", kind)])

  if username.isSome():
    let payload = RegisterReqName(
      auth: auth,
      device_id: deviceId,
      password: password,
      username: username
    )
    return PureRequest(
      endpoint: target,
      data: payload.toJson()
    )
  else:
    let payload = RegisterReq(
      auth: auth,
      device_id: deviceId,
      password: password,
    )
    return PureRequest(
      endpoint: target,
      data: payload.toJson()
    )


proc newRegisterRes(res: PureResponse): RegisterRes =
  return res.body.fromJson(RegisterRes)

proc register*(
  client: MatrixClient,
  username: string,
  password: string,
  deviceId: string = ""
): Future[RegisterRes] {.fastSync.} =
  let
    device = if len(deviceId) == 0: none(string) else: some(deviceId)
    req = newRegisterReq(
      client,
      username = some(username),
      password = password,
      deviceId = device
    )
    resp = await client.request(req)
  return newRegisterRes(resp)

proc registerGuest*(
  client: MatrixClient,
  deviceId: string = ""
): Future[RegisterRes] {.fastSync.} =
  let
    device = if len(deviceId) == 0: none(string) else: some(deviceId)
    req = newRegisterReq(
      client,
      deviceId = device
    )
    res = await client.request(req)

  return newRegisterRes(res)

proc newChangePasswordReq(
  client: MatrixClient,
  username,
  password,
  newPassword: string,
  logoutAll: bool
): PureRequest =
  let
    target = accountPassword.build(client.server)
    payload = ChangePasswordReq(
      new_password: newPassword,
      logout_devices: logoutAll,
      auth: AccountAuth(
        `type`: PASS_AUTH,
        password: password,
        identifier: AccountId(
          `type`: ID_USER_TYPE,
          user: username
        )
      )
    )

  return PureRequest(
    endpoint: target,
    data: payload.toJson()
  )

proc changePassword*(
  client: MatrixClient,
  username,
  password,
  newPassword: string,
  logoutAll: bool = false
): Future[bool] {.fastSync.} =
  let
    req = newChangePasswordReq(
      client = client,
      username = username,
      password = password,
      newPassword = newPassword,
      logoutAll = logoutAll
    )
    future = client.request(req)
  when client is AsyncMatrixClient:
    discard await future
    return not future.failed()
  else:
    discard future
    return true

proc newUserAvailableReq(
  client: MatrixClient,
  username: string
): PureRequest =
  var target = accountAvailability.build(client.server)
  target.addQuery({"username": username})
  return PureRequest(
    endpoint: target
  )

proc newUserAvailableRes(res: PureResponse): bool =
  try:
    let parsed = res.body.fromJson(UsernameAvailableRes)
    return parsed.availability
  except MatrixError as e:
    if e.errcode == "M_USER_IN_USE":
      return false
    raise e

proc isUsernameAvailable*(
  client: MatrixClient,
  username: string
): Future[bool] {.fastSync.} =
  let req = newUserAvailableReq(client, username)
  try:
    let res = await client.request(req)
    return newUserAvailableRes(res)
  finally:
    return false

proc newDeactivateReq(
  client: MatrixClient,
  username,
  password: string,
  idServer: Option[string] = none(string)
): PureRequest =
  let
    target = accountDeactivate.build(client.server)
    payload = DeactivateReq(
      id_server: idServer,
      auth: AccountAuth(
        `type`: PASS_AUTH,
        password: password,
        identifier: AccountId(
          `type`: ID_USER_TYPE,
          user: username
        )
      )
    )

  return PureRequest(
    endpoint: target,
    data: payload.toJson()
  )

proc deactivate*(
  client: MatrixClient,
  username,
  password: string,
  idServer: string = ""
): Future[bool] {.fastSync.} =
  let
    idS = if len(idServer) == 0: none(string) else: some(idServer)
    req = newDeactivateReq(
      client,
      username = username,
      password = password,
      idServer = idS)
    future = client.request(req)
  when client is AsyncMatrixClient:
    discard await future
    return not future.failed()
  else:
    discard future
    return true

proc newWhoAmIReq(
    client: MatrixClient,
  ): PureRequest =
  let target = whoAmIGet.build(client.server)
  return PureRequest(endpoint: target)

proc newWhoAmIRes(res: PureResponse): WhoAmIRes =
  return res.body.fromJson(WhoAmIRes)

proc whoAmI*(
  client: MatrixClient,
): Future[WhoAmIRes] {.fastSync.} =
  let
    req = newWhoAmIReq(client)
    res = await client.request(req)
  return newWhoAmIRes(res)
