# Package
version = "0.1.0"
author = "Dylan Hackworth"
description = "A Matrix (https://matrix.org) client and appservice API wrapper for Nim!"
license = "GPL-3.0-only"
srcDir = "src"


# Dependencies
requires "nim >= 1.5.1"
requires "jsony 1.0.5"

when defined(js):
  requires "nodejs >= 16.0.0"
