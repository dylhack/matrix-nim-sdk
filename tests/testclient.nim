import std/strformat
import std/times
import std/unittest
import "./config"
import matrix

let
  username = getUsername()
  password = getPassword()
  homeserver = getServer()

let client = newMatrixClient(homeserver)

suite "5.0 Client Authentication":
  teardown:
    client.dropToken()

  suite "5.5 Login Endpoints":
    test "client can login":
      try:
        let loginResp = client.login(username, password)
        check (len(loginResp.token) > 0)
      except MatrixError as e:
        fail()
        echo e.error

    test "client can logout":
      try:
        let loginResp = client.login(username, password)
        client.setToken loginResp.token
        let resp = client.logout()
        check resp
      except MatrixError as e:
        fail()
        echo e.error

    test "client can logout all":
      try:
        let loginResp = client.login(username, password)
        client.setToken loginResp.token
        let resp = client.logoutAll()
        check resp
      except MatrixError as e:
        fail()
        echo e.error



  suite "5.6 Account Registration and Management":
    var now = toUnixFloat getTime()
    var user = fmt"user-{now}"
    var pass = fmt"pass-{now}"

    test "client can register":
      try:
        let resp = client.register(user, pass)
        check (len(resp.token) > 0)
      except MatrixError as e:
        fail()
        echo e.error

    test "client can register as guest":
      try:
        let resp = client.registerGuest(pass)
        check (len(resp.token) > 0)
      except MatrixError as e:
        fail()
        echo e.error

    test "client can change password":
      try:
        let loginRes = client.login(user, pass)
        client.setToken(loginRes.token)
        let resp = client.changePassword(user, pass, pass)
        check resp
      except MatrixError as e:
        fail()
        echo e.error

    test "client can check username availability":
      try:
        let loginRes = client.login(user, pass)
        client.setToken(loginRes.token)
        let resp = client.isUsernameAvailable(user)
        check (not resp)
      except MatrixError as e:
        fail()
        echo e.error

    test "client can deactivate account":
      try:
        let loginRes = client.login(user, pass)
        client.setToken(loginRes.token)
        let resp = client.deactivate(user, pass)
        check resp
      except MatrixError as e:
        fail()
        echo e.error
