when defined(js):
  import std/asyncjs
  import nodejs/jsmultisync
  export asyncjs, jsmultisync
else:
  import std/asyncdispatch
  export asyncdispatch

import pkg/asyncutils
export asyncutils
