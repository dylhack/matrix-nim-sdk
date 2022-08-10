import
  std/[unittest, strformat],
  pkg/matrix/utils/endutils,
  pkg/matrix/clientserver/endpoints

suite "endutils testing":
  const server = "https://newcircuit.io"
  func expect(target: string): string =
    return fmt"{server}{target}"
  test "can build plain endpoint":
    const expected = expect loginSubmit.path
    let endpoint = loginSubmit.build server
    check ($endpoint == expected)

  test "can build param based endpoint":
    const expected = expect(
      "/_matrix/client/r0/user/%40dylhack%3Anewcircuit.io/filter/1"
    )
    let endpoint = filterGet.build(
      server,
      pathParams = [("userId", "@dylhack:newcircuit.io"), ("filterId", "1")]
    )
    echo $endpoint
    check ($endpoint == expected)

  test "can build query param based endpoint":
    const expected = expect(
      "/_matrix/client/r0/register?kind=guest"
    )
    let endpoint = accountRegister.build(
      server,
      queryParams = [("kind", "guest")]
    )
    check ($endpoint == expected)