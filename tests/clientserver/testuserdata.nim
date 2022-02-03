import std/unittest
import ../config
import matrix

let
  username = getUsername()
  password = getPassword()
  homeserver = getServer()

let client = newMatrixClient(homeserver)

suite "User data":
  setup:
    try:
      let loginRes = client.login(username, password)
      client.setToken(loginRes.accessToken)
    except MatrixError as e:
      fail()
      echo e.error

  teardown:
    client.dropToken()

  suite "Profiles":
    test "Set displayname":
      try:
        let
          whoAmIResp = client.whoAmI()
          res = client.setDisplayname(whoAmIResp.userId, "testDisplayname")
        check res
      except MatrixError as e:
        fail()
        echo e.error
