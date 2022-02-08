# Package
version = "0.1.0"
author = "Dylan Hackworth"
description = "A Matrix (https://matrix.org) client and appservice API wrapper for Nim!"
license = "GPL-3.0-only"
srcDir = "src"


# Dependencies
requires "nim >= 1.5.1"
requires "jsony#d0e69bddf83874e15b5c2f52f8b1386ac080b443"
requires "nodejs"

when defined(js):
  requires "nodejs >= 16.0.0"
