## This is the entry point for interacting with
## the Matrix Client-Server API. You can grab
## a client by calling ``newMatrixClient``.
import asyncdispatch
from httpclient import AsyncHttpClient, newAsyncHttpClient
from strformat import fmt

type MatrixClient = object
  http: AsyncHttpClient
  server: Uri

proc request*(
  var client: MatrixClient,
  endpoint: Endpoint,
  body: string
): void =
  return

proc setToken*(var client: MatrixClient, token: string): void =
  client.http.headers["Authorization"] = fmt"Bearer {token}"

proc login*(
  var client: MatrixClient,
  let username: string,
  let password: string,
  let deviceId: string): Future[void] {.async.} =
  let token = await fetchToken(username, password, deviceId)
  client.setToken token


proc getHttpCl(): AsyncHttpClient =
  return newAsyncHttpClient(
    headers: newHttpHeaders({ "Content-Type": "application/json" })
  )

proc newMatrixClient*(homeserver: string): MatrixClient = 
  ## create a new ``Matrix Client``, make sure to call ``login``
  ## to get the token, then ``start`` to start receiving events 
  ## from your homeserver.
  return MatrixClient(
    http: getHttpCl(),
    dispatcher: newDispatcher(),
    server: homeserver)

proc newMatrixClient*(homeserver: string, token: string): MatrixClient =
  ## create a new ``Matrix Client``, make sure to call ``start``
  ## to start receiving events from your homeserver.
  var result = newMatrixClient homeserver
  result.setToken token
