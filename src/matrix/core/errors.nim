import std/json

type MatrixError* {.pure.} = ref object of CatchableError
  errcode*: string
  error*: string

type UnknownError* {.pure.} = ref object of CatchableError
  body*: string

proc buildMxError*(body: string): MatrixError =
  var data = parseJson(body)
  if not data.contains("error") or not data.contains("errcode"):
    let unknown = UnknownError(body: body)
    raise unknown
  var message = data["error"].getStr()
  var code = data["errcode"].getStr()
  return MatrixError(errcode: code, error: message)
