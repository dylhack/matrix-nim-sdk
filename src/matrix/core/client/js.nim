## This is the frontend JavaScript iteration of the MatrixClient. This module
## should match up with native.nim and have the same publicly accessible 
## procedures and types.
import std/[dom, strformat,
  jsfetch, uri, jsheaders,
  jsffi, httpcore, macros]
import jsony
import pure
import ../endutils
import ../../asyncutils

type
  JsHttpClient* = object
    ## This is our own custom implementation of an HttpClient. This exists
    ## because both AsyncHttpClient and HttpClient both have a headers
    ## property, so this brings consistency since there isn't an
    ## HttpClient for JavaScript.
    headers*: Headers
  JsMatrixClient* = MatrixClient[JsHttpClient]
  # HACK(dylhack): AsyncMatrixClient and SyncMatrixClient allows us to use
  # the multisync pragma everywhere despite JavaScript only accepting async
  # code.
  AsyncMatrixClient* = JsMatrixClient
  SyncMatrixClient* = JsMatrixClient

MatrixClient.setSync(SyncMatrixClient)
MatrixClient.setAsync(AsyncMatrixClient)

proc replaceReturn(node: var NimNode) =
  var z = 0
  for s in node:
    var son = node[z]
    let jsResolve = ident("jsResolve")
    if son.kind == nnkReturnStmt:
      let value = if son[0].kind != nnkEmpty: nnkCall.newTree(jsResolve, son[
          0]) else: jsResolve
      node[z] = nnkReturnStmt.newTree(value)
    elif son.kind == nnkAsgn and son[0].kind == nnkIdent and $son[0] == "result":
      node[z] = nnkAsgn.newTree(son[0], nnkCall.newTree(jsResolve, son[1]))
    else:
      replaceReturn(son)
    inc z

proc isFutureVoid(node: NimNode): bool =
  result = node.kind == nnkBracketExpr and
    node[0].kind == nnkIdent and $node[0] == "Future" and
    node[1].kind == nnkIdent and $node[1] == "void"

proc generateJsasync(arg: NimNode): NimNode =
  if arg.kind notin {nnkProcDef, nnkLambda, nnkMethodDef, nnkDo}:
    error("Cannot transform this node kind into an async proc." &
      " proc/method definition or lambda node expected.")

  result = arg
  var isVoid = false
  let jsResolve = ident("jsResolve")
  if arg.params[0].kind == nnkEmpty:
    result.params[0] = nnkBracketExpr.newTree(ident("Future"), ident("void"))
    isVoid = true
  elif isFutureVoid(arg.params[0]):
    isVoid = true

  var code = result.body
  replaceReturn(code)
  result.body = nnkStmtList.newTree()

  if len(code) > 0:
    var awaitFunction = quote:
      proc await[T](f: Future[T]): T {.importjs: "(await #)", used.}
    result.body.add(awaitFunction)

    var resolve: NimNode
    if isVoid:
      resolve = quote:
        var `jsResolve` {.importjs: "undefined".}: Future[void]
    else:
      resolve = quote:
        proc jsResolve[T](a: T): Future[T] {.importjs: "#", used.}
        proc jsResolve[T](a: Future[T]): Future[T] {.importjs: "#", used.}
    result.body.add(resolve)
  else:
    result.body = newEmptyNode()
  for child in code:
    result.body.add(child)

  if len(code) > 0 and isVoid:
    var voidFix = quote:
      return `jsResolve`
    result.body.add(voidFix)

  let asyncPragma = quote:
    {.codegenDecl: "async function $2($3)".}

  result.addPragma(asyncPragma[0])

proc newRequest(data: PureRequest): (Request, FetchOptions) =
  var req = newRequest(($data.endpoint.target).cstring)
  var fReq = newFetchOptions(
    metod = data.endpoint.httpMethod,
    body = data.data.cstring,
    mode = fmCors,
    credentials = fcOmit,
    cache = fchNoCache,
    referrerPolicy = frpNoReferrer,
    keepalive = false)

  return (req, fReq)

proc getHttpCl(): JsHttpClient =
  let headers = newHeaders()
  for pair in defaultHeaders:
    let (key, val) = pair
    headers[key.cstring] = val.cstring

  return JsHttpClient(headers: headers)

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
    let
      (req, fReq) = newRequest(req)
      resp = await fetch(req, fReq)
      body = await resp.text()

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

## Dummy multisync, not for practical use, but for
## being able to use multisync for both native and
## JavaScript code. This will only output async code.
macro multisync*(prc: untyped): untyped =
  result = newStmtList()
  result.add generateJsasync(prc)

## Create a new JsMatrixClient
proc newMatrixClient*(homeserver: string): JsMatrixClient =
  let server = parseUri(homeserver)
  return JsMatrixClient(
    http: getHttpCl(),
    server: server
  )

## Create a new JsMatrixClient with a token already preset.
proc newMatrixClient*(homeserver: string, token: string): JsMatrixClient =
  result = newMatrixClient(homeserver)
  result.setToken token

## Create a new JsMatrixClient (alias for newMatrixClient(homeserver))
proc newAsyncMatrixClient*(homeserver: string): JsMatrixClient =
  return newMatrixClient(homeserver)

## Create a new JsMatrixClient (alias for newMatrixClient(homeserver, token))
proc newAsyncMatrixClient*(homeserver: string, token: string): JsMatrixClient =
  return newMatrixClient(homeserver, token)

## This procedure performs a HTTP request.
proc request*(
  client: JsMatrixClient,
  req: PureRequest
): Future[PureResponse] {.async.} =
  let
    (reqs, fReq) = newRequest(req)
    resp = await fetch(reqs, fReq)
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
