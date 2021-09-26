## Used by native and js
import std/uri
import std/strformat
import std/httpcore
import "../endutils"

type
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
  defaultHeaders* = {"Content-Type": "application/json"}

func setToken*[T](client: MatrixClient[T], token: string): void =
  client.http.headers["Authorization"] = fmt"Bearer {token}"

func dropToken*[T](client: MatrixClient[T]): void =
  client.http.headers.del("Authorization")
