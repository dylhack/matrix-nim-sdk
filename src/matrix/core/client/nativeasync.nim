import std/asyncdispatch
import std/httpclient
import std/httpcore
import std/json
import std/uri
import "../endutils"
import "../errors"
import "./pure"

type AsyncMatrixClient* = MatrixClient[AsyncHttpClient]

proc getAsyncCl(): AsyncHttpClient =
  return newAsyncHttpClient(headers = newHttpHeaders(defaultHeaders))

proc newAsyncMatrixClient*(homeserver: string): AsyncMatrixClient =
  let server = parseUri homeserver
  return AsyncMatrixClient(
    http: getAsyncCl(),
    server: server)

proc newAsyncMatrixClient*(
  homeserver: string,
  token: string
): AsyncMatrixClient =
  result = newAsyncMatrixClient homeserver
  result.setToken token

proc handleRateLimit(
  client: AsyncMatrixClient,
  req: PureRequest,
  payload: string
): Future[PureResponse] {.async.} =
  var parsed = parseJson(payload)

  while true:
    let retryAfterMs = parsed["retry_after_ms"].getFloat()
    await sleepAsync(retryAfterMs)
    let resp = await client.http.request(
      url = $req.endpoint,
      httpMethod = $req.endpoint.httpMethod,
      body = req.data)
    let code = resp.code()
    let body = await resp.body()

    if not code.is2xx():
      let err = buildMxError(body)
      if err.errcode == "M_LIMIT_EXCEEDED":
        parsed = parseJson(body)
        continue
      else:
        raise err
    else:
      return PureResponse(
        code: code,
        body: body,
        headers: resp.headers,
      )

proc request*(
  client: AsyncMatrixClient,
  req: PureRequest,
): Future[PureResponse] {.async.} =
  let resp = await client.http.request(
    url = $req.endpoint,
    httpMethod = $req.endpoint.httpMethod,
    body = req.data)

  let code = resp.code()
  let payload = await resp.body()
  if not code.is2xx():
    let err = buildMxError(payload)
    if err.errcode == "M_LIMIT_EXCEEDED":
      return await client.handleRateLimit(req, payload)
    raise err

  return PureResponse(
    code: code,
    body: payload,
    headers: resp.headers
  )
