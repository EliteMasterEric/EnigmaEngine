
# Friday Night Funkin': Enigma Engine

Enigma Engine is a fork of Kade Engine. I made it because I wanted to add a bunch of things while still working with the awesome features provided by the Kade Engine with these additional features:

* Dynamic and togglable 9K Support
	* Actually supports any number of keys from 1 to 9.
	* Includes support for custom keybinds.
* A revamped Charter
	* Supports placing 9K notes.
* Improved Code Structure and Debugging
	* `trace()` calls now use Flx.log for custom behavior, including notification beeps when errors occur.

Eventually I'm adding:
* Trophies
* Custom Note Types
* Custom Song Events (trigger animations via JSON rather than code)
* More Quality of Life Features

Enigma is made with the design philosophy that the code should be made as flexible as possible, with edge cases and specific behavior either being managed by a separate utility class (for ease of code reuse and readability) or through data files. For example, custom events and animations should be handled by Lua Modcharts while gameplay functionality like enabling 9-key for a specific song should be handled by the Song JSON data.

I mean seriously it seems like literally every mod and engine just uses a massive case structure inside PlayState.hx and I literally can't stand that.

Also re-emphasizing that this is only partially my original work, this is based heavily on Kade Engine. This is a place for modifications that don't logically fit with the vanilla game; whenever there is a feature or bugfix that IS appropriate for the vanilla game, [I make a PR for it](https://github.com/KadeDev/Kade-Engine/pulls?q=is%3Apr+author%3AMasterEric+is%3Amerged).

# Credits
### Friday Night Funkin'
 - [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programming
 - [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
 - [Kawai Sprite](https://twitter.com/kawaisprite) - Music

This game was made with love to Newgrounds and its community. Extra love to Tom Fulp.

### Kade Engine
- [KadeDeveloper](https://twitter.com/KadeDeveloper) - Maintainer and lead programmer
- [The contributors](https://github.com/KadeDev/Kade-Engine/graphs/contributors)

### Shoutouts
- [GWebDev](https://github.com/GrowtopiaFli) - Video Code
- [Rozebud](https://github.com/ThatRozebudDude) - Ideas (that I stole)
- [Puyo](https://github.com/puyoxyz) - Setting up appveyor and a lot of other help
- [Smokey](https://github.com/Smokey555) - telling me that I should do the tricky asset loading
- [Poco](https://github.com/poco0317) - math degree (aka most of the fucking math in this project)
