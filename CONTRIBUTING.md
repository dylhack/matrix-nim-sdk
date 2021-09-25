# Contributing
Read this before contributing to the project!

## Versioning (Semver 2)
Versions are displayed as so: `x.y.z` (0.1.0). For more details on how this
versioning is made please go-to [https://semver.org/](https://semver.org/).
Otherwise here is the TL;DR:
 * x: A breaking change was made (major)
 * y: A backwards compatibile change was made (minor)
 * z: A backwards compatible patch was made (patch)

## Project Structure
```
src/
||
||-core/
||
|+-appservice/
|  |
|  +-feature/
|
+--client/
   |
   +-feature/
```

Everything relies on the core modules. It will also help prevent merge
conflicts if all of the essentials are done and out of the way. The second
helpful approach for preventing merge conflicts is isolating each feature in
it's own folder under whatever category it fits under.

The client folder is dedicated towards the Client-Server API for Matrix. The
appservice folder is dedicated towards the Appservice-Server API for Matrix.
Each feature relating to one of those API's is isolated in it's own folder.


## Making a Module
If you're working on a new file (aka module) this is the structure of which
your module should follow in sequential order.
 1. Imports / Includes
 2. Type Definitions
 3. Constants
 4. Procedures
 5. Exports

## Commenting
Every type should follow:
 1. Summary.
 2. API reference link (if it's made from the Matrix API).

Every procedure / function:

 3. Possible errors that could raise.

## Deprecation Respecting
This project is deprecation respecting. Each public accessible feature should
be deprecated over removal or refactoring. If a feature needs refactored keep
it internal as much as possible, if parameters or a type need to change then
follow deprecating it with the `deprecated` pragma. If the feature absolutely
needs to get removed or revamped then it will be directly done so with a
major version bump.

## Testing
Unit testing is a pain, but it is absolutely needed for any feature added to
this library so that it doesn't break before it gets to production. If it is
Client-Server related then it should go under tests/clientserver/, if it is
appservice related then it should go under tests/appservice/, and if it is
core related then it should go under tests/core/.

