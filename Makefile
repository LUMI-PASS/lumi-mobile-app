.PHONY: clean gen

clean:
	flutter clean
	flutter pub get

# Regenerate all codegen: routes (auto_route), assets/images (flutter_gen),
# freezed / json / injectable, etc. Uses --delete-conflicting-outputs to drop
# stale generated files. NOTE: that flag also deletes lib/common/gen/strings.g.dart
# (its @SheetLocalization generator is commented out), so we restore it after.
gen:
	dart run build_runner build --delete-conflicting-outputs
	@git checkout -- lib/common/gen/strings.g.dart 2>/dev/null || true
