## 5.6 Account registration and management
## https://matrix.org/docs/spec/client_server/r0.6.1#account-registration-and-management

type
  RegisterRes {.pure.} = object
    userId: string
    token: string
    deviceId: string
