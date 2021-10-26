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

## Code Coverage

I haven't gotten code coverage working yet. I think coverage reports are only generated when using `haxelib run munit test` but when I do that, the build process stalls midway through, so I've resorted to running `lime test` in the test directory, which doesn't produce coverage data but does return a test result report.
