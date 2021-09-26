import std/httpclient
import std/httpcore
import std/json
import std/os
import std/uri
import "../endutils"
import "../errors"
import "./pure"

type SyncMatrixClient* = MatrixClient[HttpClient]

proc getHttpCl(): HttpClient =
  return newHttpClient(headers = newHttpHeaders(defaultHeaders))

proc newMatrixClient*(homeserver: string): SyncMatrixClient =
  let server = parseUri homeserver
  return SyncMatrixClient(
    http: getHttpCl(),
    server: server)

proc newMatrixClient*(
  homeserver: string,
  token: string
): SyncMatrixClient =
  result = newMatrixClient homeserver
  result.setToken token

proc handleRateLimit(
  client: SyncMatrixClient,
  req: PureRequest,
  payload: string
): PureResponse =
  var parsed = parseJson(payload)

  while true:
    let retryAfterMs = parsed["retry_after_ms"].getInt()
    os.sleep(retryAfterMs)
    let resp = client.http.request(
      url = $req.endpoint,
      httpMethod = $req.endpoint.httpMethod,
      body = req.data)

    let code = resp.code()
    let payload = resp.body
    if not code.is2xx():
      let err = buildMxError(payload)
      if err.errcode == "M_LIMIT_EXCEEDED":
        parsed = parseJson(payload)
        continue
      else:
        raise err
    else:
      return PureResponse(
        code: code,
        body: payload,
        headers: resp.headers
      )

proc request*(
  client: SyncMatrixClient,
  req: PureRequest
): PureResponse =
  let resp = client.http.request(
    url = $req.endpoint,
    httpMethod = $req.endpoint.httpMethod,
    body = req.data)
  let code = resp.code()
  let body = resp.body

  if not code.is2xx():
    let err = buildMxError(body)
    if err.errcode == "M_LIMIT_EXCEEDED":
      return client.handleRateLimit(req, body)
    raise err
  return PureResponse(
    code: code,
    body: body,
    headers: resp.headers
  )
