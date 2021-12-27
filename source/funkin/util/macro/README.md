# funkin.util.macro

Contains macros and utilities to assist with creating macros.

A macro contains code which is executed when the project is BUILT, rather than when the executable is run. This allows you to do things like inject new properties into existing classes.

Some examples include:
- `HaxeCommit` retrieves the the current Git commit hash of the project and inserts it as a value of a static final variable.
- `HaxeRelative` and `HaxeRotatable` add new fields that let you move an object relative to the parent, and rotate a sprite in 3D, respectively.
- `HaxeFlxZLevel` adds a new integer field, `zIndex`, to an existing class from a dependency (Flixel).
