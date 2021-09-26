# Package

version       = "0.1.0"
author        = "Dylan Hackworth"
description   = "A Matrix (https://matrix.org) client and appservice API wrapper for Nim!"
license       = "GPL-3.0-only"
srcDir        = "src"


# Dependencies
requires "nim >= 1.4.8"

when defined(js):
  requires nodejs
