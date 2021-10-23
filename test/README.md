# tests

Yes, a unit test suite for a game.

I wanted to implement SOME kind of code coverage because I keep getting ugly regressions and the only way to detect them is to play through the whole game.

## Running Tests

To run the unit tests for each platform:

```
lime test windows -DexecuteTests
lime test html5 -DexecuteTests
```