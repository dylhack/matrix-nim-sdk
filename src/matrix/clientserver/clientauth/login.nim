import
  std/[httpcore, options],
  ../../core,
  ../../utils,
  ../endpoints,
  types
include ../../utils/jsonyutils

createRequest logout:
  endPoint:
    endpoints.logout
  output: bool
  responseHandler:
    result = response.code.is2xx()

createRequest logoutAll:
  endPoint:
    endpoints.logoutAll
  output: bool
  responseHandler:
    result = response.code.is2xx()

createRequest login:
  endPoint:
    loginSubmit
  input:
    (userName, password): string
    deviceId = none(string)
    `type`{.constant.} = "m.login.password"
  output:
    (userId, accessToken, deviceId): string
    wellKnown: Option[DiscoveryInfo]
