import asyncdispatch
import httpclient
import httpcore
import json
import "./client"
import "./endutils"
import "./errors"

proc handleRateLimit(
  client: MatrixClient,
  endpoint: Endpoint,
  data: string = "",
  payload: string
): Future[AsyncResponse] {.async.} =
  ## This will continously retry the request
  ## until it stops getting rate limited.
  var parsed = parseJson(payload)

  while true:
    let retryAfterMs = parsed["retry_after_ms"].getFloat()
    await sleepAsync(retryAfterMs)
    let resp = await client.http.request(
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

proc request*(
  client: MatrixClient,
  endpoint: Endpoint,
  data: string = ""
): Future[AsyncResponse] {.async.} =
  let resp = await client.http.request(
    url = $endpoint,
    httpMethod = $endpoint.httpMethod,
    body = data)

  let code = resp.code()
  if not code.is2xx():
    let body = await resp.body()
    let err = buildMxError(body)
    if err.errcode == "M_LIMIT_EXCEEDED":
      return await client.handleRateLimit(endpoint, data, body)
    raise err
  return resp

