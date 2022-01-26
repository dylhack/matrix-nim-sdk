import std/options

type
  AuthData* = object of RootObj
    `type`*: string
    session*: Option[string]

  AccountId* = object
    `type`*: string
    user*: string

  AccountAuth* = object of AuthData
    password*: string
    identifier*: AccountId

  UserIdentifier* = object
    idType*: string

  IdentityServerInfo* = object
    baseUrl*: string

  HomeServerInfo* = object
    baseUrl*: string

  DiscoveryInfo* = object
    homeserver*: HomeServerInfo
    identityServer*: Option[IdentityServerInfo]
