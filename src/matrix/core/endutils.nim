## Endpoint utilities
import std/uri
import std/strformat
import std/strutils
import std/httpcore

type
  Endpoint* {.pure.} = object
    target*: Uri
    httpMethod*: HttpMethod
  EndpointDraft* {.pure.} = object
    ## see ``build`` to look on how an
    ## ``EndpointDraft`` becomes an
    ## ``Endpoint``
    path*: string
    httpMethod: HttpMethod

func `$`*(e: Endpoint): string =
  return $e.target

func `$`*(e: EndpointDraft): string =
  return e.path

func newDraft*(path: string, `method`: HttpMethod): EndpointDraft =
  return EndpointDraft(
    path: path,
    httpmethod: `method`
  )

func addQuery*(e: var Endpoint, query: openArray[(string, string)]): void =
  e.target.query = encodeQuery(query)

func build*(
  endpoint: EndpointDraft,
  homeserver: Uri,
  params: varargs[(string, string)] = []): Endpoint =
  ## This builds the draft into an Endpoint by
  ## formatting the path, joining the with the
  ## homeserver provided, and into an Endpoint.

  # Format the path
  var formatted = endpoint.path

  # NOTE(dylhack): I know multiReplace exists
  # but this loop must exist to make sure it
  # all gets encoded properly to be RFC3986
  # compliant
  for param in items params:
    let (key, val) = param
    let encoded = encodeUrl val
    formatted = replace(formatted, fmt"%{key}", encoded)

  # Join it all together
  var target = homeserver / formatted
  return Endpoint(target: target, httpMethod: endpoint.httpMethod)

func build*(
  endpoint: EndpointDraft,
  homeserver: string,
  params: varargs[(string, string)] = []): Endpoint =
  var server = parseUri(homeserver)
  return endpoint.build(server, params)
