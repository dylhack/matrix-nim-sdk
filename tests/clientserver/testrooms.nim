import
  std/unittest,
  pkg/matrix,
  ../config

suite "10.0 Rooms":
  setup:
    let
      username = getUsername()
      password = getPassword()
      homeserver = getServer()
      client = newMatrixClient(homeserver)

    try:
      let loginRes = client.login(username, password)
      client.setToken(loginRes.accessToken)
    except MatrixError as e:
      fail()
      echo e.error

  teardown:
    client.dropToken()

  suite "10.1 Creation":
    test "10.1.1: login and create room":
      try:
        let res = client.createRoom()
      except MatrixError as e:
        fail()
        echo e.error

    test "10.2.1: login and create room alias":
      try:
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
        let
          roomId = "matrix:matrix.org"
          res = client.joinRoom(roomId)
        check res.roomId == roomId
      except MatrixError as e:
        fail()
        echo e.error
