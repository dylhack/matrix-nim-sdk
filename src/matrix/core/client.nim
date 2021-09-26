when defined(nodejs):
  include "./client/backendjs"
elif defined(js):
  include "./client/frontendjs"
else:
  include "./client/native"
