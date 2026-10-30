#!/usr/bin/env bats
# Unit tests for the pure functions in mkmaciso. They run on Linux:
# the script is loaded with MKMACISO_TEST=1, which skips the macOS check and the CLI.

setup() {
    SCRIPT="${BATS_TEST_DIRNAME}/../mkmaciso"
}

# Run a snippet with the script loaded in test mode
load_and_run() {
    run bash -c 'MKMACISO_TEST=1; source "$0"; '"$1" "$SCRIPT"
}

@test "loading the script in test mode runs nothing" {
    load_and_run 'echo loaded'
    [ "$status" -eq 0 ]
    [ "$output" = "loaded" ]
}

@test "get_version_number maps codenames to version numbers" {
    load_and_run 'get_version_number lion; get_version_number bigsur; get_version_number tahoe'
    [ "$output" = "$(printf '10.7\n11\n26')" ]
}

@test "get_version_number returns nothing for an unknown codename" {
    load_and_run 'get_version_number nope'
    [ -z "$output" ]
}

@test "get_codename maps version numbers to codenames" {
    load_and_run 'get_codename 10.7; get_codename 15; get_codename 26'
    [ "$output" = "$(printf 'Lion\nSequoia\nTahoe')" ]
}

@test "get_codename returns nothing for an unknown version" {
    load_and_run 'get_codename 99'
    [ -z "$output" ]
}

@test "get_installer_app_name returns the installer app name" {
    load_and_run 'get_installer_app_name 26'
    [ "$output" = "Install macOS Tahoe" ]
}

@test "normalize_image_format defaults an empty format to iso" {
    load_and_run 'IMAGE_FORMAT=""; normalize_image_format; echo "$IMAGE_FORMAT"'
    [ "$output" = "iso" ]
}

@test "normalize_image_format accepts iso and dmg in any case" {
    load_and_run 'IMAGE_FORMAT="DMG"; normalize_image_format; echo "$IMAGE_FORMAT"'
    [ "$output" = "dmg" ]
}

@test "normalize_image_format rejects an unknown format with status 1" {
    load_and_run 'IMAGE_FORMAT="pdf"; normalize_image_format'
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid image format 'pdf'"* ]]
}

@test "resolve_version accepts a version number" {
    load_and_run 'VERSION="14"; resolve_version; echo "$VERSION_NUM $VERSION_NAME"'
    [ "$output" = "14 Sonoma" ]
}

@test "resolve_version accepts a codename with spaces and dashes" {
    load_and_run 'VERSION="Mountain Lion"; resolve_version; echo "$VERSION_NUM $VERSION_NAME"'
    [ "$output" = "10.8 Mountain_Lion" ]
}

@test "resolve_version rejects an unknown version with status 1" {
    load_and_run 'VERSION="99"; resolve_version'
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown macOS version: 99"* ]]
}
