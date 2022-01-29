## This is the frontend JavaScript iteration of the MatrixClient. This module
## should match up with native.nim and have the same publicly accessible
## procedures and types.
import
  std/[dom, strformat, uri, jsheaders, httpcore],
  pkg/jsony,
  pkg/nodejs/jsmultisync,
  pkg/nodejs/experimental/jshttpclient
  pure,
  ../endutils,
  ../../asyncutils

type
  AsyncMatrixClient* = MatrixClient[JsAsyncHttpClient]
  SyncMatrixClient* = MatrixClient[JsHttpClient]

MatrixClient.setAsync(AsyncMatrixClient)
MatrixClient.setSync(SyncMatrixClient)

proc newRequest(data: PureRequest): JsRequest =
  return newJsRequest(
    url = ($data.endpoint.target).cstring,
    `method` = data.endpoint.httpMethod,
    body = data.data.cstring
  )

proc setTimeoutAsync(ms: int): Future[void] =
  let promise = newPromise() do (res: proc(): void):
    discard setTimeout(res, ms)
  return promise

proc handleRateLimit(
  client: JsMatrixClient,
  req: PureRequest,
  payload: string
): Future[PureResponse] {.async.} =
  var parsed = payload.fromJson(RateLimitError)

  while true:
    await setTimeoutAsync(parsed.retryAfterMs)
    var req: Request = newRequest(req)
    req.headers = client.headers
    let
      resp = await client.request(req)
      payload = await resp.text()

    if not resp.ok:
      let str = $body
      let err = buildMxError(str)
      if err.errcode == "M_LIMIT_EXCEEDED":
        parsed = str.fromJson(RateLimitError)
        continue
      else:
        raise err
    else:
      let
        casted = cast[int](resp.status)
        ckeys = resp.headers.keys()
      var headers = newHttpHeaders()
      for ckey in ckeys:
        let
          cval = resp.headers[ckey]
          key = $ckey
          val = $cval
        headers[key] = val
      return PureResponse(
        body: $payload,
        code: cast[HttpCode](casted),
        headers: headers)

## Create a new blocking MatrixClient.
proc newMatrixClient*(homeserver: string): SyncMatrixClient =
  let server = parseUri(homeserver)
  return JsMatrixClient(
    http: newJsHttpClient(),
    server: server
  )

## Create a new MatrixClient with a token already preset.
proc newMatrixClient*(homeserver: string, token: string): SyncMatrixClient =
  result = newMatrixClient(homeserver)
  result.setToken token

## Create a new non-blocking MatrixClient.
proc newAsyncMatrixClient*(homeserver: string): AsyncMatrixClient =
  let server = parseUri(homeserver)
  return JsMatrixClient(
    http: newJsAsyncHttpClient(),
    server: server
  )

## Create a new non-blocking MatrixClient with a token already set.
proc newAsyncMatrixClient*(homeserver: string, token: string): AsyncMatrixClient =
  result = newAsyncMatrixClient(homeserver)
  result.setToken token

## This procedure performs a HTTP request.
proc request*(
  client: JsMatrixClient,
  req: PureRequest
): Future[PureResponse] {.async.} =
  var req: Request = newRequest(req)
  req.headers = client.headers
  let
    resp = await client.request(req)
    payload = await resp.text()

  if not resp.ok:
    # Catch Matrix errors the server gives us
    let err = buildMxError($payload)
    if err.errcode == "M_LIMIT_EXCEEDED":
      return await client.handleRateLimit(req, $payload)
    raise err
  # Parse their response and give it back as a PureResponse
  let
    casted = cast[int](resp.status)
    ckeys = resp.headers.keys()
  var headers = newHttpHeaders()
  for ckey in ckeys:
    let
      cval = resp.headers[ckey]
      key = $ckey
      val = $cval
    headers[key] = val
  return PureResponse(
    body: $payload,
    code: cast[HttpCode](casted),
    headers: headers)

export pure
