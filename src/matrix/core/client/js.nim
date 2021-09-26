## Shared js module for backendjs and up coming frontendjs module
import std/httpcore
import std/uri
import "./pure"

type
  JsHttpClient* = object
    headers*: HttpHeaders
  JsMatrixClient* = MatrixClient[JsMatrixClient]

proc getHttpCl(): JsHttpClient =
  return JsHttpClient(headers: newHttpHeaders(defaultHeaders))

proc newMatrixClient*(homeserver: string): JsMatrixClient =
  var server = parseUri homeserver
  return JsMatrixClient(
    http: getHttpCl(),
    server: server
  )

proc newMatrixClient*(homeserver: string, token: string): JsMatrixClient =
  result = newMatrixClient(homeserver)
  result.setToken token

export pure
