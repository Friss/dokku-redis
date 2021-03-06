#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
}

@test "($PLUGIN_COMMAND_PREFIX:list) with no exposed ports, no linked apps" {
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l     redis:5.0.7  running  -              -"
}

@test "($PLUGIN_COMMAND_PREFIX:list) with exposed ports" {
  dokku "$PLUGIN_COMMAND_PREFIX:expose" l 4242
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l     redis:5.0.7  running  6379->4242     -"
}

@test "($PLUGIN_COMMAND_PREFIX:list) with linked app" {
  dokku apps:create my_app
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "l     redis:5.0.7  running  -              my_app"
  dokku --force apps:destroy my_app
}

@test "($PLUGIN_COMMAND_PREFIX:list) when there are no services" {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
  run dokku "$PLUGIN_COMMAND_PREFIX:list"
  assert_contains "${lines[*]}" "There are no Redis services"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
}
