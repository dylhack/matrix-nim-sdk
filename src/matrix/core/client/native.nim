## This is the native iteration of the MatrixClient. This module should match
## up with js.nim and have the same publicly accessible procedures and types.
## The native iteration supports both blocking and asynchronous procedures
## using the multisync pragma.
import
  std/[os, httpclient, httpcore, uri],
  pkg/jsony,
  ../endutils,
  pure,
  ../../asyncutils
include ../../jsonyutils


type
  AsyncMatrixClient* = MatrixClient[AsyncHttpClient]
  SyncMatrixClient* = MatrixClient[HttpClient]

MatrixClient.setAsync(AsyncMatrixClient)
MatrixClient.setSync(SyncMatrixClient)

proc getHttpCl(): HttpClient =
  return newHttpClient(headers = newHttpHeaders(defaultHeaders))

proc getAsyncCl(): AsyncHttpClient =
  return newAsyncHttpClient(headers = newHttpHeaders(defaultHeaders))

proc handleRateLimit(
  client: MatrixClient,
  req: PureRequest,
  payload: string
): Future[PureResponse] {.fastSync.} =
  var parsed = payload.fromJson(RateLimitError)

  while true:
    when client is AsyncMatrixClient:
      await sleepAsync(parsed.retryAfterMs)
    else:
      os.sleep(parsed.retryAfterMs)
    let resp = await client.http.request(
      url = $req.endpoint,
      httpMethod = req.endpoint.httpMethod,
      body = req.data)
    let
      code = resp.code()
      body = await resp.body()

    if not code.is2xx():
      let err = buildMxError(body)
      if err.errcode == "M_LIMIT_EXCEEDED":
        parsed = body.fromJson(RateLimitError)
        continue
      else:
        raise err
    else:
      return PureResponse(
        code: code,
        body: body,
        headers: resp.headers,
      )

## Create a new blocking MatrixClient.
proc newMatrixClient*(homeserver: string): SyncMatrixClient =
  let server = parseUri homeserver
  return SyncMatrixClient(
    http: getHttpCl(),
    server: server)

## Create a new blocking MatrixClient with a token already set.
proc newMatrixClient*(
  homeserver,
  token: string
): SyncMatrixClient =
  result = newMatrixClient(homeserver)
  result.setToken(token)

## Create a new non-blocking MatrixClient.
proc newAsyncMatrixClient*(homeserver: string): AsyncMatrixClient =
  let server = parseUri(homeserver)
  return AsyncMatrixClient(
    http: getAsyncCl(),
    server: server)

## Create a new non-blocking MatrixClient with a token already set.
proc newAsyncMatrixClient*(
  homeserver,
  token: string
): AsyncMatrixClient =
  result = newAsyncMatrixClient homeserver
  result.setToken token

## This procedure performs a HTTP request.
proc request*(
  client: MatrixClient,
  req: PureRequest,
): Future[PureResponse] {.fastSync.} =
  let
    resp = await client.http.request(
      url = $req.endpoint,
      httpMethod = req.endpoint.httpMethod,
      body = req.data)
    code = resp.code()
    payload = await resp.body()

  if not code.is2xx():
    # Catch Matrix errors the server gives us
    let err = buildMxError(payload)
    if err.errcode == "M_LIMIT_EXCEEDED":
      return await client.handleRateLimit(req, payload)
    raise err
  # Parse their response and give it back as a PureResponse
  return PureResponse(
    code: code,
    body: payload,
    headers: resp.headers
  )

export pure
