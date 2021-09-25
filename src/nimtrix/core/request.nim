import asyncdispatch
import httpclient
import httpcore
import "./client"
import "./endutils"
import "./errors"

proc request*(
  client: MatrixClient,
  endpoint: Endpoint,
  body: string = ""
): Future[AsyncResponse] {.async.} =
  result = await client.http.request(
    url = $endpoint,
    httpMethod = $endpoint.httpMethod,
    body = body)

  let code = result.code()
  if not code.is2xx():
    let body = await result.body()
    var err = buildMxError(body)
    raise err
