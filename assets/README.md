# assets

What do all the folders do?

* `fonts` contains fonts for the application. These will get embedded in the EXE at build time.
* `locales` contains data for a (work-in-progress) localization/translation feature. Multi-language support for your mods!
* `songs` contains the instrumentals and voices for each song. Use `ogg` files for Desktop and `mp3` for Web/HTML5.

* `preload/*` contains files used for menus, before gameplay.
* `shared/*` contains files used for gameplay.

* The base game creates additional files used to contain only assets for specific weeks, but that's not recommended for Enigma since you have to edit the project file as well as make modifications to ModCore's framework parameters.