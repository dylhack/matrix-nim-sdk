## Endpoint utilities for generating endpoints.
import std/[uri, strformat, strutils, httpcore]

type
  Endpoint* {.pure.} = object
    ## Endpoint holds the full URI path to the endpoint
    ## including the protocol and IP address or domain.
    target*: Uri
    httpMethod*: HttpMethod
  EndpointDraft* {.pure.} = object
    ## The EndpointDraft holds the endpoint, but
    ## doesn't have the homeserver just yet, once
    ## build(EndpointDraft) is called then it
    ## becomes an `Endpoint`.
    path*: string
    httpMethod: HttpMethod

func `$`*(e: Endpoint): string =
  return $e.target

func `$`*(e: EndpointDraft): string =
  return e.path

## This creates a new EndpointDraft, this should only be
## used by the library itself, not for outside use.
func newDraft*(path: string, `method`: HttpMethod): EndpointDraft =
  return EndpointDraft(
    path: path,
    httpmethod: `method`
  )

## Add query to the URI.
func addQuery*(e: var Endpoint, query: openArray[(string, string)]): void =
  e.target.query = encodeQuery(query)

## Build an EndpointDraft into an Endpoint. Originally the EndpointDraft only
## includes the path to the Matrix endpoint, but not the domain, port, or
## protocol (http / https).
func build*(
  endpoint: EndpointDraft,
  homeserver: Uri,
  pathParams, queryParams: varargs[(string, string)] = []): Endpoint =
  ## This builds the draft into an Endpoint by
  ## formatting the path, joining the with the
  ## homeserver provided, and into an Endpoint.

  # Format the path
  var formatted = endpoint.path

  # NOTE(dylhack): I know multiReplace exists
  # but this loop must exist to make sure it
  # all gets encoded properly to be RFC3986
  # compliant
  for param in items pathParams:
    let
      (key, val) = param
      encoded = encodeUrl val
    formatted = replace(formatted, fmt"%{key}", encoded)

  # Join it all together
  let target = homeserver / formatted ? queryParams
  return Endpoint(target: target, httpMethod: endpoint.httpMethod)

## Alias for build(Endpoint).
func build*(
  endpoint: EndpointDraft,
  homeserver: string,
  pathParams, queryParams: varargs[(string, string)] = []): Endpoint =
  var server = parseUri homeserver
  return endpoint.build(server, pathParams, queryParams)
