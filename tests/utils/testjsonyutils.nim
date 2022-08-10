import std/unittest
include pkg/matrix/utils/jsonyutils

type
  TestRes = object
    testField: string

suite "jsonyutils testing":
  test "camelCase to snake_case":
    check TestRes(testField: "test").toJson() == """{"test_field":"test"}"""

  test "snake_case to camelCase":
    check """{"test_field":"test"}""".fromJson(TestRes)
