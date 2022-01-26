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
        let res = client.createRoom()
      except MatrixError as e:
        fail()
        echo e.error

    test "10.2.1: login and create room alias":
      try:
        let loginRes = client.login(username, password)
        client.setToken(loginRes.accessToken)
        let
          createRoomRes = client.createRoom()
          res = client.createRoomAlias("test", createRoomRes.roomId)
        check res
      except MatrixError as e:
        fail()
        echo e.error

  suite "10.4 Room membership":
    test "10.4.1: get joined rooms":
      try:
        let guestRes = client.registerGuest(password)
        client.setToken(guestRes.accessToken)
        let
          res = client.joinedRooms()
          emptySeq: seq[string] = @[]
        check res.joinedRooms == emptySeq
      except MatrixError as e:
        fail()
        echo e.error

    test "10.4.2.2: join room":
      try:
        let guestRes = client.registerGuest(password)
        client.setToken(guestRes.accessToken)
        let
          roomId = "matrix:matrix.org"
          res = client.joinRoom(roomId)
        check res.roomId == roomId
      except MatrixError as e:
        fail()
        echo e.error