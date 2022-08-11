import
  std/[strformat, times, unittest],
  pkg/matrix,
  ../config

suite "5.0 Client Authentication":
  setup:
    let
      username = getUsername()
      password = getPassword()
      homeserver = getServer()
      client = newMatrixClient(homeserver)

  teardown:
    client.dropToken()

  suite "5.5 Login Endpoints":
    test "client can login":
      try:
        let loginResp = client.login(username, password)
        check (len(loginResp.accessToken) > 0)
      except MatrixError as e:
        fail()
        echo e.error

    test "client can logout":
      try:
        let loginResp = client.login(username, password)
        client.setToken loginResp.accessToken
        let resp = client.logout()
        check resp
      except MatrixError as e:
        fail()
        echo e.error

    test "client can logout all":
      try:
        let loginResp = client.login(username, password)
        client.setToken loginResp.accessToken
        let resp = client.logoutAll()
        check resp
      except MatrixError as e:
        fail()
        echo e.error

  suite "5.6 Account Registration and Management":
    let
      now = toUnixFloat getTime()
      user = fmt"user-{now}"
      pass = fmt"pass-{now}"

    test "client can register":
      try:
        let resp = client.register(user, pass)
        check (len(resp.accessToken) > 0)
      except MatrixError as e:
        fail()
        echo e.error

    test "client can register as guest":
      try:
        let resp = client.registerGuest(pass)
        check (len(resp.accessToken) > 0)
      except MatrixError as e:
        fail()
        echo e.error

    test "client can change password":
      try:
        let loginRes = client.login(user, pass)
        client.setToken(loginRes.accessToken)
        let resp = client.changePassword(user, pass, pass)
        check resp
      except MatrixError as e:
        fail()
        echo e.error

    test "client can check username availability":
      try:
        let loginRes = client.login(user, pass)
        client.setToken(loginRes.accessToken)
        let resp = client.isUsernameAvailable(user)
        check (not resp)
      except MatrixError as e:
        fail()
        echo e.error

    test "client can deactivate account":
      try:
        let loginRes = client.login(user, pass)
        client.setToken(loginRes.accessToken)
        let resp = client.deactivate(user, pass)
        check resp
      except MatrixError as e:
        fail()
        echo e.error

    test "client can check who am i":
      try:
        let loginRes = client.login(user, pass)
        client.setToken(loginRes.accessToken)
        let whoAmIResp = client.whoAmI()
        check whoAmIResp.userId == user
      except MatrixError as e:
        fail()
        echo e.error
