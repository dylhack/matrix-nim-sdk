when defined(js):
  import std/asyncjs
  export asyncjs
else:
  import std/asyncdispatch
  export asyncdispatch

import std/[macros, macrocache]

const asyncCache = CacheSeq"AsyncCache"

macro setSync*(t: typedesc, syncType: typed) =
  if syncType.kind != nnkSym:
    error("`syncType` needs to be a type for the sync operation.", syncType)
  block add:
    for x in asyncCache:
      if x[0].eqIdent(t.repr):
        x[2] = syncType
        break add
    asyncCache.add newStmtList(ident(t.repr), newEmptyNode(), syncType)

macro setAsync*(t: typedesc, asyncType: typed) =
  if t.kind != nnkSym:
    error("`asyncType` needs to be a typeclass for subscribing.", asyncType)
  if asyncType.kind != nnkSym:
    error("`asyncType` needs to be a type for the async operation.", asyncType)
  block add:
    for x in asyncCache:
      if x[0].eqIdent(t):
        x[1] = asyncType
        break add
    asyncCache.add newStmtList(ident(t.repr), asyncType, newEmptyNode())

proc getTypeclass(n: NimNode): NimNode =
  for x in asyncCache:
    if x[0].eqIdent(n):
      if x[1].kind != nnkSym:
        error("Unset async type for " & $n, n)
      if x[2].kind != nnkSym:
        error("Unset sync type for " & $n, n)
      result = nnkInfix.newTree(ident"or", x[1], x[2])
  if result.isNil:
    error("Neither sync or async types set for " & n.repr, n)

macro fastSync*(pdef: untyped): untyped =
  ## Uses the stored values from `setAsync`/`setSync` to allow the usage of type classes
  let typ = pdef.params[1][^2].getTypeclass
  if typ != nil:
    result = pdef.copyNimTree()
    result.params[1][^2] = typ
    result[4] = nnkPragma.newTree(ident"multisync")
