## This is the entry point for interacting with
## the Matrix Client-Server API. You can grab
## a client by calling ``newMatrixClient``.
import httpclient
import strformat
import uri

type
  MatrixClient* {.pure.} = object
    http*: AsyncHttpClient
    server*: Uri

func setToken*(client: MatrixClient, token: string): void =
  client.http.headers["Authorization"] = fmt"Bearer {token}"

func dropToken*(client: MatrixClient): void =
  client.http.headers.del("Authorization")

proc getHttpCl(): AsyncHttpClient =
  return newAsyncHttpClient(
    headers = newHttpHeaders({"Content-Type": "application/json"})
  )

proc newMatrixClient*(homeserver: string): MatrixClient =
  ## create a new ``Matrix Client``, make sure to call ``login``
  ## to get the token, then ``start`` to start receiving events
  ## from your homeserver.
  let server = parseUri homeserver
  return MatrixClient(
    http: getHttpCl(),
    server: server)

proc newMatrixClient*(homeserver: string, token: string): MatrixClient =
  ## create a new ``Matrix Client``, make sure to call ``start``
  ## to start receiving events from your homeserver.
  result = newMatrixClient homeserver
  result.setToken token
