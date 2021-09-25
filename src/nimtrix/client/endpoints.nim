from strformat import fmt
from httpcore import HttpMethod
import "../core/endutils"

const prefix = "/_matrix/client/r0"

func newClDraft(endpoint: string, `method`: HttpMethod): EndpointDraft =
  ## Create new Client-Server API endpoint draft
  return newDraft(fmt"{prefix}{endpoint}", `method`)

const
  # -------------------------- 05 Client Authentication --------------------- #
  ## https://matrix.org/docs/spec/client_server/r0.6.1#client-authentication
  ## 5.5 Login Endpoints
  ## https://matrix.org/docs/spec/client_server/r0.6.1#login
  loginGet* = newClDraft("/login", HttpGet)
  loginSubmit* = newClDraft("/login", HttpPost)
  logout* = newClDraft("/logout", HttpPost)
  logoutAll* = newClDraft("/logout/all", HttpPost)

  ## 5.6 Account registration and management
  ## https://matrix.org/docs/spec/client_server/r0.6.1#account-registration-and-management
  accountRegister* = newClDraft("/register", HttpPost)
  accountAvailability* = newClDraft("/register/available", HttpGet)
  accountPassword* = newClDraft("/account/password", HttpPost)
  accountDeactivate* = newClDraft("/account/deactivate", HttpPost)

  ## 5.7 Adding Account Administrative Contact Information
  ## https://matrix.org/docs/spec/client_server/r0.6.1#adding-account-administrative-contact-information
  thirdPidGet* = newClDraft("/account/3pid", HttpGet)
  thirdPidAdd* = newClDraft("/account/3pid/add", HttpPost)
  thirdPidBind* = newClDraft("/account/3pid/bind", HttpPost)
  thirdPidUnbind* = newClDraft("/account/3pid/unbind",HttpPost)
  thirdPidDelete* = newClDraft("/account/3pid/delete", HttpPost)

  ## 5.8 Current account information
  ## https://matrix.org/docs/spec/client_server/r0.6.1#current-account-information
  whoAmI* = newClDraft("/account/whoami", HttpGet)

  ## 6 Capabilities negotiation
  ## https://matrix.org/docs/spec/client_server/r0.6.1#capabilities-negotiation
  capabilitiesGet* = newClDraft("/capabilities", HttpGet)

  ## 8 Filtering
  ## https://matrix.org/docs/spec/client_server/r0.6.1#filtering
  filterGet* = newClDraft("/user/%userId/filter/%filterId", HttpGet)
  filterSubmit* = newClDraft("/user/%userId/filter", HttpPost)



  # -------------------------- 09 Events ---------------------------------- #
  ## https://matrix.org/docs/spec/client_server/r0.6.1#events

  ## 9.4 Syncing
  ## https://matrix.org/docs/spec/client_server/r0.6.1#syncing
  Sync* = newClDraft("/sync", HttpGet)

  ## 9.5 Getting events for a room
  ## https://matrix.org/docs/spec/client_server/r0.6.1#getting-events-for-a-room
  roomEventGet* = newClDraft("/rooms/%roomId/event/%eventId", HttpGet)
  roomStateEventGet* = newClDraft(
    "/rooms/%roomId/state/%eventType/%stateKey",
    HttpGet)
  roomStateGet* = newClDraft("/rooms/%roomId/state", HttpGet)
  roomMembersGet* = newClDraft("/rooms/%roomId/members", HttpGet)
  roomJoinedMembersGet* = newClDraft("/rooms/%roomId/joined_members", HttpGet)
  roomMessagesGet* = newClDraft("/rooms/%roomId/messages", HttpGet)

  ## 9.6 Sending events to a room
  ## https://matrix.org/docs/spec/client_server/r0.6.1#sending-events-to-a-room
  roomStateEventPut* = newClDraft(
    "/rooms/%roomId/state/%eventType/%stateKey",
    HttpPut)
  roomEventPut* = newClDraft(
    "/rooms/%roomId}/send/%eventType/%txnId",
    HttpPut)

  ## 9.7 Redactions
  ## https://matrix.org/docs/spec/client_server/r0.6.1#redactions
  eventRedactPut* = newClDraft(
    "/rooms/%roomId/redact/%eventId/%txnId",
    HttpPut)



  # -------------------------- 10 Rooms ----------------------------------- #
  ## https://matrix.org/docs/spec/client_server/r0.6.1#rooms
  ## 10.1 Creation
  roomCreate* = newClDraft("/createRoom", HttpPost)

  ## 10.2 Room aliases
  ## https://matrix.org/docs/spec/client_server/r0.6.1#room-aliases
  roomAliasPut* = newClDraft("/directory/room/%roomAlias", HttpPut)
  roomAliasGet* = newClDraft("/directory/room/%roomAlias", HttpGet)
  roomAliasDelete* = newClDraft("/directory/room/%roomAlias", HttpDelete)
  roomAliasesGet* = newClDraft("/rooms/%roomId/aliases", HttpGet)

  ## 10.4 Room membership
  ## https://matrix.org/docs/spec/client_server/r0.6.1#room-membership
  joinedRoomsGet* = newClDraft("/joined_rooms", HttpGet)

  ## 10.4.2 Joining rooms
  ## https://matrix.org/docs/spec/client_server/r0.6.1#joining-rooms
  memberInvite* = newClDraft("/rooms/%roomId/invite", HttpPost)
  roomJoinId* = newClDraft("/rooms/%roomId/join", HttpPost)
  roomJoinAlias* = newClDraft("/join/%roomIdOrAlias", HttpPost)

  ## 10.4.3 Leaving rooms
  ## https://matrix.org/docs/spec/client_server/r0.6.1#leaving-rooms
  roomLeave* = newClDraft("/rooms/%roomId/leave", HttpPost)
  roomForget* = newClDraft("/rooms/%roomId/forget", HttpPost)
  memberKick* = newClDraft("/rooms/%roomId/kick", HttpPost)

  ## 10.4.4 Banning users in a room
  ## https://matrix.org/docs/spec/client_server/r0.6.1#banning-users-in-a-room
  memberBan* = newClDraft("/rooms/%roomId/ban", HttpPost)
  memberPardon* = newClDraft("/rooms/%roomId/unban", HttpPost)

  ## 10.5 Listing rooms
  ## https://matrix.org/docs/spec/client_server/r0.6.1#listing-rooms
  roomVisibilityGet* = newClDraft("GET /directory/list/room/%roomId", HttpGet)
  roomVisibilityPut* = newClDraft("PUT /directory/list/room/%roomId", HttpPut)
  publicRoomsGet* = newClDraft("GET /publicRooms", HttpGet)
  publicRoomsPut* = newClDraft("POST /publicRooms", HttpPost)



  # -------------------------- 11 User Data ------------------------------- #
  ## https://matrix.org/docs/spec/client_server/r0.6.1#user-data
  ## 11.1 User Directory
  ## https://matrix.org/docs/spec/client_server/r0.6.1#user-directory
  userSearchSubmit* = newClDraft("/user_directory/search", HttpPost)

  ## 11.2 Profiles
  ## https://matrix.org/docs/spec/client_server/r0.6.1#profiles
  profileNamePut* = newClDraft("/profile/%userId/displayname", HttpPut)
  profileNameGet* = newClDraft("/profile/%userId/displayname", HttpGet)
  profileAvatarPut* = newClDraft("/profile/%userId/avatar_url", HttpPut)
  profileAvatarGet* = newClDraft("/profile/%userId/avatar_url", HttpGet)
  profileGet* = newClDraft("/profile/%userId", HttpGet)



  # -------------------------- 13 Modules --------------------------------- #
  ## https://matrix.org/docs/spec/client_server/r0.6.1#modules

  ## 13.3.3 TURN Server behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id47
  turnServerGet* = newClDraft("/voip/turnServer", HttpGet)

  ## 13.4.2 Typing Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id51
  typingPut* = newClDraft("/rooms/{roomId}/typing/{userId}", HttpPut)

  ## 13.5.2 Receipts Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id55
  receiptsSubmit* = newClDraft(
    "/rooms/%roomId/receipt/%receiptType/%eventId",
    HttpPost)

  ## 13.6.2 Fully Read Markers Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id60
  readMarkersSubmit* = newClDraft("/rooms/%roomId/read_markers", HttpPost)

  ## 13.7.2 Presence Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id64
  presenceGet* = newClDraft("/presence/%userId/status", HttpGet)
  presencePut* = newClDraft("/presence/%userId/status", HttpPut)

  ## 13.8.2 Content Repository Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id67
  uploadFile* = newClDraft("/media/r0/upload", HttpPost)
  downloadMedia* = newClDraft("/download/%serverName/%mediaId", HttpGet)
  downloadFile* = newClDraft(
    "/download/%serverName/%mediaId/%fileName",
    HttpGet)
  downloadThumbnail* = newClDraft("/thumbnail/%serverName/%mediaId", HttpGet)
  previewUrl* = newClDraft("/preview_url", HttpGet)
  contentRepoConfigGet* = newClDraft("/config", HttpGet)

  ## 13.10.1 Device Management Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id74
  devicesGet* = newClDraft("/devices", HttpGet)
  deviceGet* = newClDraft("/devices/%deviceId", HttpGet)
  devicePut* = newClDraft("/devices/%deviceId", HttpPut)
  deviceDelete* = newClDraft("/devices/%deviceId", HttpDelete)
  devicesDelete* = newClDraft("/delete_devices ", HttpPost)

  ## 13.11.5.2 End-to-End Encryption Key management API
  ## https://matrix.org/docs/spec/client_server/r0.6.1#key-management-api
  keyUpload* = newClDraft("/keys/upload", HttpPost)
  keyQuery* = newClDraft("/keys/query", HttpPost)
  keyClaim* = newClDraft("/keys/claim", HttpPost)
  keyChangesGet* = newClDraft("/keys/changes", HttpGet)

  ## 13.13.1 Push Notifications Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id90
  pushersGet* = newClDraft("/pushers", HttpGet)
  pushersSet* = newClDraft("/pushers/set", HttpPost)

  ## 13.13.1.3 Listing Notifications
  ## https://matrix.org/docs/spec/client_server/r0.6.1#listing-notifications
  notificationsGet* = newClDraft("/notifications", HttpGet)

  ## 13.13.1.6 Push Rules: API
  ## https://matrix.org/docs/spec/client_server/r0.6.1#push-rules-api
  pushRulesGet* = newClDraft("/pushrules", HttpGet)
  pushRulesScopeGet* = newClDraft("/pushrules/%scope/%kind/%ruleId", HttpGet)
  pushRulesDelete* = newClDraft("/pushrules/%scope/%kind/%ruleId", HttpDelete)
  pushRulesPut* = newClDraft("/pushrules/%scope/%kind/%ruleId", HttpPut)
  pushRulesEnabledGet* = newClDraft(
    "/pushrules/%scope/%kind/%ruleId/enabled",
    HttpGet)
  pushRulesEnabledPut* = newClDraft(
    "/pushrules/%scope/%kind/%ruleId/enabled",
    HttpPut)
  pushRulesActionsGet* = newClDraft(
    "/pushrules/%scope/%kind/%ruleId/actions",
    HttpGet)
  pushRulesActionsPut* = newClDraft(
    "/pushrules/%scope/%kind/%ruleId/actions",
    HttpPut)

  ## 13.14.2 Third Party Invites Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id100
  memberInviteThirdParty* = newClDraft("/rooms/%roomId/invite", HttpPost)

  ## 13.15.1 Server Side Search Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id105
  search* = newClDraft("/search", HttpPost)

  ## 13.17.1 Room Previews Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id117
  roomPreviewEvents* = newClDraft("/events", HttpGet)

  ## 13.18.2 Room Tagging Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id124
  roomTagGet* = newClDraft("GET /user/%userId/rooms/%roomId/tags", HttpGet)
  roomTagPut* = newClDraft(
    "PUT /user/%userId/rooms/%roomId/tags/%tag",
    HttpPut)
  roomTagDelete* = newClDraft(
    "DELETE /user/%userId/rooms/%roomId/tags/%tag",
    HttpDelete)

  ## 13.19.2 Client Config Client Behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id127
  accountDataPut* = newClDraft("PUT /user/%userId/account_data/%type", HttpPut)
  accountDataGet* = newClDraft("GET /user/%userId/account_data/%type", HttpGet)
  roomDataPut* = newClDraft(
    "PUT /user/%userId/rooms/%roomId/account_data/%type",
    HttpPut)
  roomDataGet* = newClDraft(
    "GET /user/%userId/rooms/%roomId/account_data/%type",
    HttpGet)

  ## 13.20.1 Server Administration Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id130
  whoIs* = newClDraft("/admin/whois/{userId}", HttpGet)

  ## 13.21.1 Event Context Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id132
  eventContextGet* = newClDraft("/rooms/%roomId/context/%eventId", HttpGet)

  ## 13.26.1 Reporting Content Client behaviour
  ## https://matrix.org/docs/spec/client_server/r0.6.1#id151
  RoomEventReport* = newClDraft("/rooms/%roomId/report/%eventId", HttpPost)

  ## 13.27.1 Third Party Networks Lookups
  ## https://matrix.org/docs/spec/client_server/r0.6.1#third-party-lookups
  thirdPartyProtocolsGet* = newClDraft("/thirdparty/protocols", HttpGet)
  thirdPartyProtocolGet* = newClDraft(
    "/thirdparty/protocol/%protocol",
    HttpGet)
  thirdPartyProtocolLocation* = newClDraft(
    "/thirdparty/location/%protocol",
    HttpGet)
  thirdPartyProtocolUser* = newClDraft("/thirdparty/user/{protocol}", HttpGet)
  thirdPartyLocation* = newClDraft("/thirdparty/location", HttpGet)
  thirdPartyUser* = newClDraft("/thirdparty/user", HttpGet)

  ## 13.31.2 Room Upgrades Client behaviour
  roomUpgrade* = newClDraft("/rooms/%roomId/upgrade", HttpPost)

export endutils
