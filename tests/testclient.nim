import asyncdispatch except fail
import nimtrix
import os
import unittest

const username = getEnv("MX_USER", "")
const password = getEnv("MX_PASS", "")
const homeserver = getEnv("MX_SERVER", "")
let client = newMatrixClient(homeserver)

proc login(): Future[string] {.async.} =
  let resp = await client.login(username, password)
  return resp.token

suite "test 5.5 Login Endpoints":
  test "username and password env are set":
    check (len(username) != 0)
    check (len(password) != 0)
  test "client can login successfully":
    try:
      let token = waitFor login()
      check (len(token) != 0)
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
