# 1.0.0-nullsafety.0

- **BREAKING**: migrated to null safety
- feat!: upgrade Dart SDK constraints to `>=2.12.0-0 <3.0.0`
- chore: updated flutter version in CI to latest

# 0.4.0+1

- chore: github action publish issue resolution

# 0.4.0

- feat: added functionality to read local json
- feat: added timeOut reference for request function to override global behaviour
- fix: assertions being caught
- fix: removed extra bracket from log
- docs: added example for local read, log feature and timeOut
- docs: added badges :)
- docs: updated old examples
- refactor: achieved 100% code coverage
- refactor: added padentic linter
- refactor: avoided dublication for hydrated cubit and extended the existing cubit instead
- chore: removed unnecessary code and imports

# 0.3.2

- feat: added option to enable log for a request function
- feat: used copyWith to allow cubit to retain model data on error and loading states
- feat: added format exception if unable to convert json to model
- chore: removed request model since it's no longer being used

# 0.3.1

- docs: spell corrections
- refactor: added pedantic as linter for package
# 0.3.0

- feat: use of copy with to retain model data on state change
- chore: bumped flutter_bloc to `flutter_bloc: ^6.1.3`
- chore: bumped meta to `^1.2.2`
- docs: added not for copywith change

# 0.2.0

- Added a request function to handle Future requests

# 0.1.1

- Unused import removed

# 0.1.0

- Initial Release