import std/unittest
import ../config
import matrix

let
  username = getUsername()
  password = getPassword()
  homeserver = getServer()

let client = newMatrixClient(homeserver)

suite "10.0 Rooms":
  teardown:
    client.dropToken()

  suite "10.1 Creation":
    test "10.1.1: login and create room":
      try:
        let loginRes = client.login(username, password)
        client.setToken(loginRes.accessToken)
        let createRoomRes = client.createRoom()
        check createRoomRes
      except MatrixError as e:
        fail()
        echo e.error
