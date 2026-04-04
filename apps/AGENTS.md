# LUA applications

## LUA language

Use LUA 5.5 syntax

* Use const for constants
* Tab size 2, replace tabs with spaces.
* Never use single line conditionals if/else/elseif. Break on several lines
* never use "string" calls like print"Hello" always use braces: print("Hello")

## Applications

* esp32 - main application for ESP32 board.
* exp32_test
    EXP32 API simulator. Used for testing purposes.
    Injects fake esp32 API which ise used by other apps.
    Runs along with esp32 app.

* login - login web interface. all applications must redirect to /api/login if user is not authenticated.
* mock_sso - a mock SSO server for testing purposes.

## Application structure

Every application must have the following structure:

* root folder contains react project if it has web interface.
* lsp_app - LUA/LSP code
  * root folder contains lsp files.
  * `.lua` folder contains lua files.




## build application

During build need to copy content of lsp_app to destination folder with web application.
