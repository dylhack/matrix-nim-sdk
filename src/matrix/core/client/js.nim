## This is the frontend JavaScript iteration of the MatrixClient. This module
## should match up with native.nim and have the same publicly accessible
## procedures and types.
import
  std/[dom, strformat, uri, jsheaders, httpcore],
  pkg/nodejs/jshttpclient,
  pure,
  ../endutils,
  ../../asyncutils
include ../../jsonyutils


type
  AsyncMatrixClient* = MatrixClient[JsAsyncHttpClient]
  SyncMatrixClient* = MatrixClient[JsHttpClient]

MatrixClient.setAsync(AsyncMatrixClient)
MatrixClient.setSync(SyncMatrixClient)

proc newRequest(req: PureRequest): JsRequest =
  return newJsRequest(
    url = ($req.endpoint.target).cstring,
    `method` = req.endpoint.httpMethod,
    body = req.data.cstring
  )

proc setTimeoutSync(ms: int) = {.emit: "setTimeout(function() { }, `ms`);".}

proc setTimeoutAsync(ms: int): Future[void] =
  let promise = newPromise() do (res: proc(): void):
    discard setTimeout(res, ms)
  return promise

proc handleRateLimit(
  client: MatrixClient,
  request: PureRequest,
  payload: string
): Future[PureResponse] {.fastsync.} =
  var parsed = payload.fromJson(RateLimitError)

  while true:
    when client is AsyncMatrixClient:
      await setTimeoutAsync(parsed.retryAfterMs)
    else:
      setTimeoutSync(parsed.retryAfterMs)
    let
      req = newRequest(request)
      resp = await client.http.request(req)
      body = resp.responseText

    if not resp.status.is2xx():
      let str = $body
      let err = buildMxError(str)
      if err.errcode == "M_LIMIT_EXCEEDED":
        parsed = str.fromJson(RateLimitError)
        continue
      else:
        raise err
    else:
      let ckeys = resp.headers.keys()
      var headers = newHttpHeaders()
      for ckey in ckeys:
        let
          cval = resp.headers[ckey]
          key = $ckey
          val = $cval
        headers[key] = val
      return PureResponse(
        body: $payload,
        code: resp.status,
        headers: headers)

proc addHeaders*(client: MatrixClient, headers = defaultHeaders) =
  for (key, value) in headers:
    client.http.headers[key.cstring] = value.cstring

## Create a new blocking MatrixClient.
proc newMatrixClient*(homeserver: string): SyncMatrixClient =
  let server = parseUri(homeserver)
  result = SyncMatrixClient(
    http: newJsHttpClient(),
    server: server
  )
  result.addHeaders()

## Create a new MatrixClient with a token already preset.
proc newMatrixClient*(homeserver: string, token: string): SyncMatrixClient =
  result = newMatrixClient(homeserver)
  result.setToken token

## Create a new non-blocking MatrixClient.
proc newAsyncMatrixClient*(homeserver: string): AsyncMatrixClient =
  let server = parseUri(homeserver)
  result = AsyncMatrixClient(
    http: newJsAsyncHttpClient(),
    server: server
  )
  result.addHeaders()

## Create a new non-blocking MatrixClient with a token already set.
proc newAsyncMatrixClient*(homeserver: string, token: string): AsyncMatrixClient =
  result = newAsyncMatrixClient(homeserver)
  result.setToken token

## This procedure performs a HTTP request.
proc request*(
  client: MatrixClient,
  request: PureRequest
): Future[PureResponse] {.fastsync.} =
  let
    req = newRequest(request)
    resp = await client.http.request(req)
    payload = resp.responseText

  if not resp.status.is2xx():
    # Catch Matrix errors the server gives us
    let err = buildMxError($payload)
    if err.errcode == "M_LIMIT_EXCEEDED":
      return await client.handleRateLimit(request, $payload)
    raise err
  # Parse their response and give it back as a PureResponse
  let ckeys = resp.headers.keys()
  var headers = newHttpHeaders()
  for ckey in ckeys:
    let
      cval = resp.headers[ckey]
      key = $ckey
      val = $cval
    headers[key] = val
  return PureResponse(
    body: $payload,
    code: resp.status,
    headers: headers)

export pure
