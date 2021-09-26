## Backend JavaScript support (NodeJS)
import std/asyncjs
import std/strformat
import std/json
import std/jsffi
import nodejs/jshttp
import "../endutils"

proc handleRateLimit*(
  client: JsMatrixClient,
  endpoint: Endpoint,
  body: string = ""
): Future[Response] {.async.} =
  var parsed = parseJson(payload)

  while true:
    let retryAfterMs = parsed["retry_after_ms"].getFloat()
    await sleepAsync(retryAfterMs)
    let resp = await client.request(
      url = $endpoint,
      httpMethod = $endpoint.httpMethod,
      body = data)

    let code = resp.code()
    if not code.is2xx():
      let payload = await resp.body()
      let err = buildMxError(payload)
      if err.errcode == "M_LIMIT_EXCEEDED":
        parsed = parseJson(payload)
        continue
      else:
        raise err
    else:
      return resp

  return

proc request*(
  client: JsMatrixClient,
  endpoint: Endpoint,
  body: string = ""
): Future[PureResponse] {.async.} =
  let options = {
    "method": $endpoint.httpMethod,
    "headers": client.http.headers
  }.toJs()
  let promise = newPromise() do (res: proc(result: Response)):
    requestHttps($endpoint, options, proc(req: HttpClientRequest))

  return promise

