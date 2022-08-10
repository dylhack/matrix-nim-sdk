import
  std/tables,
  ../../core,
  ../../utils,
  ../endpoints,
  types
include ../../utils/jsonyutils


type
  SyncReq* = object
    filter*: string
    since*: string
    fullState*: bool
    setPresence*: PresenceState
    timeout*: int
  SyncRes* = object
    accountData*: AccountData
    deviceLists*: DeviceLists
    deviceOneTimeKeysCount*: Table[string, int]
    nextBatch*: string
    presence*: Presence
    rooms*: Rooms
    toDevice*: ToDevice

proc newSyncReq(
    client: MatrixClient,
    filter, since: string,
    fullState: bool,
    setPresence: PresenceState,
    timeout: int
  ): PureRequest =
  let target = syncGet.build(client.server, queryParams = [("filter", filter), ("since", since), ("full_state", $fullState), ("set_presence", $setPresence), ("timeout", $timeout)])
  return PureRequest(endpoint: target)

proc newSyncRes(res: PureResponse): SyncRes =
  return res.body.fromJson(SyncRes)

proc sync*(
    client: MatrixClient,
    filter, since: string = "",
    fullState: bool = false,
    setPresence: PresenceState = PresenceState.online,
    timeout: int = 0
  ): Future[SyncRes] {.fastsync.} =
  let
    req = newSyncReq(
      client,
      filter,
      since,
      fullState,
      setPresence,
      timeout
    )
    res = await client.request(req)
  return newSyncRes(res)
