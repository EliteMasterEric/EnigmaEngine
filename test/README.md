# tests

Yes, a unit test suite for a game.

I wanted to implement SOME kind of code coverage because I keep getting ugly regressions and the only way to detect them is to play through the whole game.

## Running Tests

To run the unit tests for each platform (replace `windows` with whatever platform you want), perform one of the following (from most to least convenient):

* Install the Haxe Test Explorer and click the arrow at the top.
* Run `./test.bat` on Windows or `./test.sh`
* Run the following command to run tests on a specific platform.
```
haxelib run munit gen
haxelib run lime test <platform>
```