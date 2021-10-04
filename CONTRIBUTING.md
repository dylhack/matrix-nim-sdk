# Contributing
Read this before contributing to the project!

## Versioning (Semver 2)
Versions are displayed as so: `x.y.z` (0.1.0). For more details on how this
versioning is made please go-to [https://semver.org/](https://semver.org/).
Otherwise here is the TL;DR:
 * x: A breaking change was made (major)
 * y: A backwards compatibile change was made (minor)
 * z: A backwards compatible patch was made (patch)

As a contributor you will not need to worry about what commits or tags get versioned. That will be done by the maintainer(s) each release.

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
+--clientserver/
   |
   +-feature/
```

Everything relies on the core modules. This will help prevent merge conflicts if all of the essentials are done and out of the way. The second helpful approach for preventing merge conflicts is isolating each feature in it's own folder under whatever category it fits under (client-server / appservice).

The clientserver folder is dedicated towards the Client-Server API for Matrix. The appservice folder is dedicated towards the Appservice-Server API for Matrix. As for utilities, if they're shared amongst both then they will go under `src/utils`.

## Making a Module
If you're working on a new file (aka module) this is the structure of which your module should follow in sequential order.
 1. Imports / Includes
 2. Type Definitions
 3. Constants
 4. Private Procedures
 5. Public Procedures
 6. Exports

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
Unit testing is a pain, but it is absolutely needed for any feature added to this library so that it doesn't break before it gets to production. If it is Client-Server related then it should go under `tests/clientserver`, if it is appservice related then it should go under `tests/appservice`, and if it is core related then it should go under `tests/core`.

## Purity
Keeping the library pure is probably the number one longest task when adding your feature. To test that your feature is "pure" make sure you have unit tests written for native and NodeJS and run `nimble test` for each platform.

**Frontend JavaScript is not testable** yet. Because the tests have to be performed in a browser this isn't automated yet using `nimble test`, but eventually we will run a headless browser (a driver) and communicate the test results back to the parent process (Nimble), for now you may skip testing frontend.

## Branching
Make sure that whatever feature is being worked on has it's own branch. If you are a contributor on the GitHub repository.
