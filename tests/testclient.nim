import asyncdispatch except fail
import matrix
import os
import unittest
import strformat
import times

const
  username = getEnv("MX_USER", "")
  password = getEnv("MX_PASS", "")
  homeserver = getEnv("MX_SERVER", "")
let client = newMatrixClient(homeserver)

proc login(): Future[string] {.async.} =
  let resp = await client.login(username, password)
  return resp.token

suite "5.5 Login Endpoints":
  test "username and password env are set":
    check (len(username) != 0)
    check (len(password) != 0)
  test "client can login":
    try:
      let token = waitFor login()
      check (len(token) > 0)
    except MatrixError as e:
      echo e.error
      fail()
  test "client can logout":
    try:
      let token = waitFor login()
      client.setToken token
      let resp = waitFor client.logout()
      check resp
    except MatrixError as e:
      echo e.error
      fail()
  test "client can logout all":
    try:
      let token = waitFor login()
      client.setToken token
      let resp = waitFor client.logoutAll()
      check resp
    except MatrixError as e:
      echo e.error
      fail()

suite "5.6 Account Registration and Management":
  var now = toUnixFloat getTime()
  var user = fmt"user-{now}"
  var pass = fmt"pass-{now}"

  test "client can register":
    try:
      client.dropToken()
      let resp = waitFor client.register(user, pass)
      check (len(resp.token) > 0)
    except MatrixError as e:
      echo e.error
      fail()
  test "client can register as guest":
    try:
      client.dropToken()
      let resp = waitFor client.registerGuest(pass)
      check (len(resp.token) > 0)
    except MatrixError as e:
      echo e.error
      fail()
  test "client can change password":
    try:
      let token = waitFor login()
      client.setToken token
      let resp = waitFor client.changePassword(username, password, password)
      check resp
    except MatrixError as e:
      echo e.error
      fail()
  test "client can check username availability":
    try:
      client.dropToken()
      let loginRes = waitFor client.login(user, pass)
      client.setToken(loginRes.token)
      let resp = waitFor client.isUsernameAvailable(user)
      check (not resp)
    except MatrixError as e:
      echo e.error
      fail()
  test "client can deactivate account":
    try:
      client.dropToken()
      let loginRes = waitFor client.login(user, pass)
      client.setToken(loginRes.token)
      let resp = waitFor client.deactivate(user, pass)
      check resp
    except MatrixError as e:
      echo e.error
      fail()
