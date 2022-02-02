import pkg/jsony

proc camel2snake*(s: string): string =
  ## CanBeFun => can_be_fun
  ## https://forum.nim-lang.org/t/1701
  result = newStringOfCap(s.len)
  for i in 0..<len(s):
    if s[i] in {'A'..'Z'}:
      if i > 0:
        result.add('_')
      result.add(chr(ord(s[i]) + (ord('a') - ord('A'))))
    else:
      result.add(s[i])

template dumpKey(s: var string, v: string) =
  # jsony hook to convert from camelCase to snake_case
  const v2 = v.camel2snake().toJson() & ":"
  s.add v2

proc dumpHook*(s: var string, v: object) =
  s.add '{'
  var i = 0
  when compiles(for k, e in v.pairs: discard):
    # Tables and table like objects.
    for k, e in v.pairs:
      if i > 0:
        s.add ','
      s.dumpHook(k)
      s.add ':'
      s.dumpHook(e)
      inc i
  else:
    # Normal objects.
    for k, e in v.fieldPairs:
      if i > 0:
        s.add ','
      s.dumpKey(k)
      s.dumpHook(e)
      inc i
  s.add '}'
