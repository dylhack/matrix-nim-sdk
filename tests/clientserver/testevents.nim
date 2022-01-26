import std/unittest
import ../config
import matrix

let
  username = getUsername()
  password = getPassword()
  homeserver = getServer()

let client = newMatrixClient(homeserver)

suite "Events":
  setup:
    try:
      let loginRes = client.login(username, password)
      client.setToken(loginRes.accessToken)
    except MatrixError as e:
      fail()
      echo e.error

  teardown:
    client.dropToken()

  suite "Syncing":
    test "sync":
      try:
        let res = client.sync()
        echo res
      except MatrixError as e:
        fail()
        echo e.error
