## Endpoint utilities
import uri
from strutils import replace
from httpcore import HttpMethod
from strformat import fmt

type
  Endpoint* = object
    target*: Uri
    `method`*: HttpMethod
  EndpointDraft* = object
    ## see ``build`` to look on how an
    ## ``EndpointDraft`` becomes an 
    ## ``Endpoint``
    path*: string
    `method`: HttpMethod 

func `$`*(e: Endpoint): string =
  return $e.target 

func `$`*(e: EndpointDraft): string =
  return e.path

func newDraft*(path: string, `method`: HttpMethod): EndpointDraft =
  return EndpointDraft(
    path: path,
    `method`: `method`
  )

func build*(
  endpoint: EndpointDraft,
  homeserver: string,
  params: varargs[(string, string)] = []): Endpoint =
  ## This builds the draft into an Endpoint by
  ## formatting the path, joining the with the 
  ## homeserver provided, and into an Endpoint.
  var server = parseUri homeserver

  # Format the path
  var formatted = endpoint.path

  # NOTE(dylhack): I know multiReplace exists
  # but this loop must exist to make sure it
  # all gets encoded properly to be RFC3986 
  # compliant
  for param in items params :
    let (key, val) = param
    let encoded = encodeUrl val
    formatted = replace(formatted, fmt"%{key}", encoded)

  # Join it all together 
  var target = server / formatted
  return Endpoint(target: target, `method`: endpoint.method)
