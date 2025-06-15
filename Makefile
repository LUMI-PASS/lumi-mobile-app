

### Generate for the main directory: 
### Example: 
### [make gen] ---- flutter pub run build_runner build --delete-conflicting-outputs 
### [make gen ENGINE="dart"] ---- dart run build_runner build --delete-conflicting-outputs
ENGINE ?= flutter pub
gen:
	$(ENGINE) run build_runner build --delete-conflicting-outputs

### Generate chess_ui_kit
### [make gen] ---- flutter pub get && flutter packages pub run build_runner build --delete-conflicting-outputs 
### [make gen ENGINE="fvm flutter"] ---- fvm flutter pub get && fvm flutter packages pub run build_runner build --delete-conflicting-outputs 
ENGINE_KIT ?= flutter
gen_kit:
	cd packages/chess_ui_kit && $(ENGINE_KIT) pub get && $(ENGINE_KIT) packages pub run build_runner build --delete-conflicting-outputs

### Gets all dependencies for project
get_all:
	flutter pub get && cd packages/chess_ui_kit && flutter pub get
