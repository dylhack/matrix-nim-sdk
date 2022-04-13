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
      except MatrixError as e:
        fail()
        echo e.error

  suite "Getting events from a room":
    test "get room event":
      try:
        let
          roomId = "matrix:matrix.org"
          eventId = "test"
          res = client.getRoomEvent(roomId, eventId)
      except MatrixError as e:
        fail()
        echo e.error

  suite "Sending events to a room":
    test "send room event":
      try:
        let
          eventType = "test"
          roomId = "matrix:matrix.org"
          event = RoomEvent()
          res = client.sendRoomEvent(eventType, roomId, event)
      except MatrixError as e:
        fail()
        echo e.error

    test "send message":
      try:
        let
          eventType = "test"
          roomId = "matrix:matrix.org"
          txnId = ""
          body = "hello world!"
          msgtype = MessageType.`m.text`
          res = client.sendMessage(eventType, roomId, txnId, body, msgtype)
      except MatrixError as e:
        fail()
        echo e.error

  suite "Room state":
    test "get room state":
      try:
        let
          roomId = "matrix:matrix.org"
          res = client.getRoomState(roomId)
      except MatrixError as e:
        fail()
        echo e.error

    test "get room messages":
      try:
        let
          syncRes = client.sync()
          roomId = "matrix:matrix.org"
          res = client.getRoomMessages(roomId, dir = Direction.forward, `from` = syncRes.nextBatch)
      except MatrixError as e:
        fail()
        echo e.error

