## 5.6 Account registration and management
## https://matrix.org/docs/spec/client_server/r0.6.1#account-registration-and-management
import asyncdispatch
import httpclient
import options
import json
import "../core"
import "./endpoints"

type
  RegisterRes* {.pure.} = object
    userId*: string
    token*: string
    deviceId*: string

proc parseRegisterRes(body: string): RegisterRes =
  let data = parseJson(body)
  return RegisterRes(
    userId: data["user_id"].getStr(),
    token: data["access_token"].getStr(),
    deviceId: data["device_id"].getStr()
  )

proc register*(
  client: MatrixClient,
  username: string,
  password: string,
  deviceId: string = ""): Future[RegisterRes] {.async.} =
  ## Register a new account with the homeserver. This
  ## will raise a MatrixError if anything went wrong.
  let target = accountRegister.build(client.server)
  let data = %* {
    "kind": "user",
    "username": username,
    "password": password,
    "auth": {
      "type": "m.login.dummy"
    }
  }
  var resp = await client.request(target, $data)
  let body = await resp.body()
  return parseRegisterRes(body)

proc registerGuest*(
  client: MatrixClient,
  password: string
): Future[RegisterRes] {.async.} =
  ## Register a new guest account with the homeserver.
  ## This will raise a MatrixError if anything went wrong.
  let target = accountRegister.build(client.server)
  let data = %* {
    "kind": "user",
    "password": password,
    "auth": %* {
      "type": "m.login.dummy"
    }
  }
  var resp = await client.request(target, $data)
  let body = await resp.body()
  return parseRegisterRes(body)

proc changePassword*(
  client: MatrixClient,
  username: string,
  password: string,
  newPassword: string,
  logoutAll: bool = false
): Future[bool] {.async.} =
  ## Change the password for the account currently
  ## logged in as. This will raise a MatrixError if
  ## anything went wrong.
  let target = accountPassword.build(client.server)
  let data = %* {
    "new_password": newPassword,
    "logout_devices": logoutAll,
    "auth": %* {
      "type": "m.login.password",
      "password": password,
      "identifier": %* {
        "type": "m.id.user",
        "user": username
      }
    }
  }
  var future = client.request(target, $data)
  discard await future
  return not future.failed()

proc isUsernameAvailable*(
  client: MatrixClient,
  username: string
): Future[bool] {.async.} =
  ## Check if a username is available. This will
  ## raise a MatrixError if anything went wrong.
  var target = accountAvailability.build(client.server)
  target.addQuery({ "username": username })

  try:
    let resp = await client.request(target)
    let parsed = parseJson(await resp.body())
    let available = parsed["availability"].getBool()
    return available
  except MatrixError as e:
    if e.errcode == "M_USER_IN_USE":
      return false
    raise e

proc deactivate*(
  client: MatrixClient,
  username: string,
  password: string,
  idServer: string = ""
): Future[bool] {.async.} =
  ## Deactivate the current account. This will raise
  ## a MatrixError if anything went wrong.
  let target = accountDeactivate.build(client.server)
  let data = %* {
    "id_server": idServer,
    "auth": %* {
      "type": "m.login.password",
      "password": password,
      "identifier": %* {
        "type": "m.id.user",
        "user": username
      }
    }
  }
  var future = client.request(target, $data)
  discard await future
  return not future.failed()

