import
  std/[macros, strformat, genasts, httpcore, strutils],
  ../core,
  ../utils
include jsonyutils

proc findNamedCommand(body: NimNode, name: string): NimNode =
  for entry in body:
    if entry.kind != nnkCall:
      error(fmt"Expected command syntax, but got '{entry.kind}'.", entry)
    if entry[0].eqIdent name:
      result = entry[1]

proc getEndPoint(body: NimNode): NimNode =
  result = body.findNamedCommand("endpoint")

  if result.kind in {nnkEmpty, nnkNilLit}:
    error("No endpoint given", body)

proc getOutput(body: NimNode): NimNode =
  result = body.findNamedCommand("output")
  if result.kind in {nnkEmpty, nnkNilLit}:
    hint("No output given, assuming `void`.", body)

proc getInput(body: NimNode): NimNode =
  result = body.findNamedCommand("input")
  if result.kind in {nnkEmpty, nnkNilLit}:
    hint("No input given, assuming no parameters.", body)

proc getResponseHandler(body: NimNode): NimNode =
  result = body.findNamedCommand("responseHandler")

proc tupleResponse(output: NimNode): bool =
  result = output.len > 1 and output[0].kind notin {nnkIdent, nnkAccQuoted}


type
  ParamType = enum
    constant

proc paramType(pragmaExpr: NimNode): ParamType =
  if pragmaExpr[1].len > 1:
    error("Too many pragmas applied to statement, expected 1", pragmaExpr)
  if pragmaExpr[1][0].eqIdent "constant":
    constant
  else:
    error(fmt"Invalid pragma {pragmaExpr[1][0].repr}.", pragmaExpr[1][0])
    constant

proc insertParameters*(prc, input: NimNode, toSerialize: var seq[NimNode]) =
  ## adds the parameters to the procedure, and stores the names of them to serialize
  for param in input:
    case param[0].kind
    of nnkPar, nnkTupleConstr:
      let identDef = nnkIdentDefs.newTree(param[0][0..^1])
      for x in identDef:
        toSerialize.add x
      case param.kind
      of nnkAsgn: # group of optional parameters `(a, b) = c`
        identDef.add newEmptyNode()
        identDef.add param[1]
      of nnkCall: # group of required parameters `(a, b): c`
        identDef.add param[1][0]
        if param[1].len == 1:
          identdef.add newEmptyNode()
      else:
        discard

      prc.params.add identDef
    of nnkIdent, nnkAccQuoted:
      let identDef = nnkIdentDefs.newTree(param[0])
      case param.kind
      of nnkAsgn: # This is a optional parameter `a = b`
        identDef.add newEmptyNode()
        identDef.add param[1]
      of nnkCall: # This is a required parameter `a: b`
        identDef.add param[1][0]
      else:
        discard
      prc.params.add identDef
    of nnkPragmaExpr:
      case param[0].paramType:
      of constant: # This is a `a {.constant.} = b`
        toSerialize.add param[0][0]
        prc.body.add:
          genast(name = param[0][0], val = param[1]):
            const name = val

    else:
      error(fmt"Unexpected kind '{param[0].kind}', expected nnkPar, nnkTupleConstr, nnkIdent or nnkPragmaExpr.", param[0])

proc makePayload(toSerialize: seq[NimNode]): NimNode =
  ## iterates the nimnodes returning a tuple of them, for serializing
  result = nnkPar.newTree()
  for val in toSerialize:
    result.add nnkExprColonExpr.newTree(val, val)

proc makeOutputType(output: NimNode): NimNode =
  ## Creates a tuple coresponding to the result type
  result = nnkTupleTy.newTree()
  for val in output:
    case val[0].kind
    of nnkPar, nnkTupleConstr:
      for ident in val[0]:
        result.add newIdentDefs(ident, val[^1])
    of nnkIdent:
      result.add newIdentDefs(val[0], val[1])
    else:
      error("Output parameters can only be '(name,): type' or `name: type'.", val)

macro createRequest*(name, body: untyped) =
  ## Creates a request given a name and DSL
  ## `endPoint` in the DSL is the value for the target endpoint.
  ## `input` is optional, it's a parameter list, though for `(a, b): int`
  ## is the way for multiple parameters.
  ## A input parameter can be annotated with `{.constant.}` to define it as constant in the procedure.
  ## `output` also can be a parameter list, which is used to generate a tuple,
  ## it can also just be a type.
  ## If it is just a type one needs to specify a `responseHandler`
  ## The `responseHandler` is code ran after the response, a `response` symbol
  ## is injected which holds the result of the response
  ## Example from 'login.nim'
  ## ```nim
  ##  createRequest login:
  ##  endPoint:
  ##    loginSubmit
  ##  input:
  ##    (userName, password): string
  ##    deviceId = none(string)
  ##    `type`{.constant.} = "m.login.password"
  ##  output:
  ##    (userId, accessToken, deviceId): string
  ##    wellKnown: Option[DiscoveryInfo]
  ## ```

  let
    endPoint = body.getEndPoint()
    output = body.getOutput()
    input = body.getInput()
    useTuple = output.tupleResponse()
    respHandler = body.getResponseHandler()
    outputType =
      if useTuple:
        output.makeOutputType()
      else:
        output
    outputFutType = nnkBracketExpr.newTree(ident"Future", outputType)

  if useTuple and respHandler.kind notin {nnkNilLit, nnkEmpty}:
    error("Given a tuple response, and a response handler.", respHandler)

  if not useTuple and respHandler.kind in {nnkNilLit, nnkEmpty}:
    error("No response handler given", body)

  var namesToSend: seq[NimNode]

  result = genast(name, outputFutType,  client = ident"client", server = bindsym"MatrixClient"):
    proc name*(client: server): outputFutType {.fastsync.} = discard
  result[^1] = newStmtList()
  result.insertParameters(input, namesToSend)

  if useTuple:
    result[^1].add:
      genAst(targetPoint = endpoint, payload = namesToSend.makePayload(), outputType, client = ident"client", response = ident"response", res = ident"result"):
        let
          req =
            when compiles((let a = payload)):
              PureRequest(
                endPoint: targetPoint.build(client.server),
                data: toJson(payload)
              )
            else:
              PureRequest(
                endPoint: targetPoint.build(client.server),
              )
          response = await client.request(req)
        res = response.body.fromJson(outputType)
  else:
    result[^1].add:
      genAst(targetPoint = endpoint, payload = namesToSend.makePayload(), respHandler, outputType, client = ident"client", response = ident"response"):
        let
          req =
            when compiles((let a = payload)):
              PureRequest(
                endPoint: targetPoint.build(client.server),
                data: toJson(payload)
              )
            else:
              PureRequest(
                endPoint: targetPoint.build(client.server),
              )
          response = await client.request(req)
        respHandler

  if useTuple:
    let tupleName = ident ($name).toUpperAscii & "Data"
    result = genAst(outputType, tupleName, res = result):
      type tupleName* = outputType
      res
