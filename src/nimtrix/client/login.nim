## 5.5 Login
## https://matrix.org/docs/spec/client_server/r0.6.1#login
import asyncdispatch
import httpclient
import options
import json
import "../core"
import "./endpoints"

type
  UserIdentifier* {.pure.} = object
    idType: string
  IdentityServerInfo* {.pure.} = object
    baseUrl: string
  HomeServerInfo* {.pure.} = object
    baseUrl: string
  DiscoveryInfo* {.pure.} = object
    homeserver: HomeServerInfo
    identityServer: Option[IdentityServerInfo]
  LoginRes* {.pure.} = object
    userId*: string
    token*: string
    deviceId*: string
    wellKnown*: Option[DiscoveryInfo]

func getWellKnown(data: JsonNode): Option[DiscoveryInfo] =
  if not data.contains("well_known"):
    return none(DiscoveryInfo)
  let wellKnownData = data["well_known"]

  # get m.homeserver
  let homeserver = block:
    let homeserverData = wellKnownData["m.homeserver"]
    let baseUrl = homeserverData["base_url"].getStr()
    HomeServerInfo(baseUrl: baseUrl)

  # get m.identity_server
  let identity = block:
    if not wellKnownData.contains("m.identity_server"):
      none(IdentityServerInfo)
    else:
      let identityData = wellKnownData["m.identity_server"]
      let baseUrl = identityData["base_url"].getStr()
      some(IdentityServerInfo(baseUrl: baseUrl))

  # finish it up
  some(DiscoveryInfo(
    homeserver: homeserver,
    identityServer: identity))

proc parseLoginRes(body: string): LoginRes =
  let data = parseJson(body)
  let userId = data["user_id"].getStr()
  let token = data["access_token"].getStr()
  let deviceId = data["device_id"].getStr()
  let wellKnown = data.getWellKnown()
  return LoginRes(
    userId: userId,
    token: token,
    deviceId: deviceId,
    wellKnown: wellKnown)


proc login*(
  client: MatrixClient,
  username: string,
  password: string,
  deviceId: string = ""
): Future[LoginRes] {.async.} =
  ## Login with a username and password
  ## with an optional device ID to set.
  ## This raises a MatrixError if
  ## anything goes wrong, like
  ## incorrect credentials.
  var target = loginSubmit.build(client.server)

  # prepare body
  var data = %* {
    "type": "m.login.password",
    "user": username,
    "password": password
  }
  if deviceId != "":
    data["device_id"] = % deviceId

  var resp = await client.request(target, $data)
  var body = await resp.body()
  return parseLoginRes(body)


proc logout*(client: MatrixClient): Future[bool] {.async.} =
  ## logout the current client, this will always
  ## return true unless a MatrixError is raised.
  var target = endpoints.logout.build(client.server)
  var future = client.request(target)
  return not future.failed()

proc logoutAll*(client: MatrixClient): Future[bool] {.async.} =
  ## logout all devices, this will always return
  ## true unless a MatrixError is raised.
  var target = endpoints.logoutAll.build(client.server)
  var future = client.request(target)
  return not future.failed()
