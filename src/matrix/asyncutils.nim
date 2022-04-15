when defined(js):
  import std/asyncjs
  export asyncjs
else:
  import std/asyncdispatch
  export asyncdispatch

import pkg/asyncutils
export asyncutils
