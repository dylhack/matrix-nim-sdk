## This is the pure client code. This is code is usable by any platform
## (JavaScript, native, etc.)
when defined(js):
  import std/jsheaders
import std/[uri, strformat, httpcore]
import jsony
import ../endutils

type
  MatrixErrorRaw* = object of RootObj
    errcode*: string
    error*: string
  MatrixError* = ref object of CatchableError
    errcode*: string
    error*: string
  RateLimitError* = object of MatrixErrorRaw
    retryAfterMs*: int
  UnknownError* = ref object of CatchableError
    body*: string
  MatrixClient*[T] = object
    http*: T
    server*: Uri
  PureRequest* = object
    endpoint*: Endpoint
    data*: string
  PureResponse* = object
    code*: HttpCode
    body*: string
    headers*: HttpHeaders

const
  ## All MatrixClients will carry these headers.
  defaultHeaders* = {"Content-Type": "application/json"}

## Set the token for the MatrixClient.
func setToken*(client: MatrixClient, token: string): void =
  when defined(js):
    client.http.headers["Authorization".cstring] = (
      fmt"Bearer {token}"
    ).cstring
  else:
    client.http.headers["Authorization"] = fmt"Bearer {token}"

## Remove the token from the MatrixClient.
func dropToken*(client: MatrixClient): void =
  when defined(js):
    client.http.headers.delete("Authorization")
  else:
    client.http.headers.del("Authorization")

## Create a new MatrixError with given JSON.
proc buildMxError*(body: string): MatrixError =
  try:
    let parsed = body.fromJson(MatrixErrorRaw)
    if len(parsed.errcode) == 0 or len(parsed.error) == 0:
      let unknown = UnknownError(body: body)
      raise unknown
    return MatrixError(errcode: parsed.errcode, error: parsed.error)
  except:
    raise UnknownError(body: body)

