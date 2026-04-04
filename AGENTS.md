# 3-D farm project

LUA backend API: https://realtimelogic.com/ba/doc/

## Project structure

* apps - folder with LSP applications in LUA language.
* xedge - ESP32 firmware based on ESP-IDF.

## Rules

* write tests for applications. Tests are not required for test/simulator devices

## Running test environment

run mako server with command:

```bash
mako -c mako-test.conf
```

It will run web server on port 9500. You can access it via browser at http://localhost:9500. Check there is no other mako instances running on port 9500.