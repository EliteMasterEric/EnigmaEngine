/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Alphabet.hx
 * Alphabet acts similarly to FlxText, but isn't.
 * It manually creates text from individual letters off a spritesheet.
 * This spritesheet is located at `assets/preload/images/alphabet.png`.
 * Fixed to allow for symbols and numbers.
 */
package funkin.ui.component;

import funkin.behavior.options.Options.AntiAliasingOption;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
import openfl.Lib;

using hx.strings.Strings;

class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var listOAlphabets:List<AlphaCharacter> = new List<AlphaCharacter>();

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	var pastX:Float = 0;
	var pastY:Float = 0;

	// ThatGuy: Variables here to be used later
	var xScale:Float;
	var yScale:Float;

	/**
	 * Creates a new `Alphabet` object to display text.
	 * @param x The x coordinate of the text.
	 * @param y The y coordinate of the text.
	 * @param text The text to display.
	 *   TODO: Does not support diacritics.
	 * @param bold Whether or not the text is bold.
	 *   TODO: Currently only supports capital letters.
	 * @param typed Whether or not the text shows a typing animation.
	 * @param xScale Horizonal scale of the text.
	 * @param yScale Vertical scale of the text.
	 */
	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, xScale:Float = 1, yScale:Float = 1)
	{
		pastX = x;
		pastY = y;

		// ThatGuy: Have to assign these variables
		this.xScale = xScale;
		this.yScale = yScale;

		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text == "")
			return;

		if (typed)
			startTypedText();
		else
			addText();
	}

	public function reType(text, xScale:Float = 1, yScale:Float = 1)
	{
		for (i in listOAlphabets)
			remove(i);
		_finalText = text;
		this.text = text;

		lastSprite = null;

		updateHitbox();

		listOAlphabets.clear();
		x = pastX;
		y = pastY;

		this.xScale = xScale;
		this.yScale = yScale;

		addText();
	}

	/**
	 * Adds the current text to the display.
	 */
	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;

		for (character in splitWords)
		{
			if (character == " " || character == "-")
			{
				lastWasSpace = true;
			}

			if (AlphaCharacter.isValid(character))
			{
				if (lastSprite != null)
				{
					// ThatGuy: This is the line that fixes the spacing error when the x position of this class's objects was anything other than 0
					xPos = lastSprite.x - pastX + lastSprite.width;
				}

				// if (lastWasSpace)
				// {
				// 	// ThatGuy: Also this line
				// 	xPos += 40 * xScale;
				// 	lastWasSpace = false;
				// }

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);

				// ThatGuy: These are the lines that change the individual scaling of each character
				letter.scale.set(xScale, yScale);
				letter.updateHitbox();

				listOAlphabets.add(letter);

				letter.createCharacter(character, isBold);
				add(letter);
				lastSprite = letter;
			}
			else
			{
				Debug.logWarn('Warning: Invalid character: $character (${character.charCodeAt8(0)})');
			}
		}
	}

	function doSplitWords():Void
	{
		// split8 splits in a manner that supports Unicode characters
		splitWords = _finalText.split8("");
	}

	public var personTalking:String = 'gf';

	// ThatGuy: THIS FUNCTION ISNT CHANGED! Because i dont use it lol
	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			if (_finalText.charCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			if (AlphaCharacter.isValid(splitWords[loopNum]))
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
				listOAlphabets.add(letter);
				letter.row = curRow;

				letter.createCharacter(splitWords[loopNum], true);

				if (!isBold)
					letter.x += 90;

				// What is this for?
				if (FlxG.random.bool(40))
				{
					var daSound:String = "GF_";
					FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
				}

				add(letter);

				lastSprite = letter;
			}
			else
			{
				Debug.logWarn('Warning: Invalid character: ${splitWords[loopNum]}');
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
			x = FlxMath.lerp(x, (targetY * 20) + 90, 0.30);
		}

		super.update(elapsed);
	}

	// ThatGuy: Ooga booga function for resizing text, with the option of wanting it to have the same midPoint
	// Side note: Do not, EVER, do updateHitbox() unless you are retyping the whole thing. Don't know why, but the position gets weird if you do that
	public function resizeText(xScale:Float, yScale:Float, xStaysCentered:Bool = true, yStaysCentered:Bool = false):Void
	{
		var oldMidpoint:FlxPoint = this.getMidpoint();
		reType(text, xScale, yScale);
		if (!(xStaysCentered && yStaysCentered))
		{
			if (xStaysCentered)
			{
				// I can just use this juicy new function i made
				moveTextToMidpoint(new FlxPoint(oldMidpoint.x, getMidpoint().y));
			}
			if (yStaysCentered)
			{
				moveTextToMidpoint(new FlxPoint(getMidpoint().x, oldMidpoint.y));
			}
		}
		else
		{
			moveTextToMidpoint(new FlxPoint(oldMidpoint.x, oldMidpoint.y));
		}
	}

	/**
	 * Ensure your text is centered on a certain point.
	 * @param midpoint The x/y point you want the text to be centered on.
	 */
	public function moveTextToMidpoint(midpoint:FlxPoint):Void
	{
		/*
			e.g. You want your midpoint at (100, 100)
			and your text is 200 wide, 50 tall
			then, x = 100 - 200/2, y = 100 - 50/2
		 */
		this.x = midpoint.x - this.width / 2;
		this.y = midpoint.y - this.height / 2;
	}
}

/**
 * This sprite represents an individual character of an Alphabet object.
 */
class AlphaCharacter extends FlxSprite
{
	/**
	 * Characters of the alphabet which we are able to render.
	 * Use toUpperCase() to check for upper case.
	 */
	public static var alphabetUpper:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

	public static var alphabetLower:String = "abcdefghijklmnopqrstuvwxyz";

	/**
	 * Numbers which we are able to render.
	 */
	public static var numbers:String = "1234567890";

	/**
	 * Symbols which we are able to render.
	 * Believe it or not we can render those emojis.
	 * Potentially add: " & ♦ ♣ ♠ ♪ ♫ ↔ ↕ ↖ ↗ ↘ ↙
	 */
	public static var symbols:String = "!#$%&'()*+,-./:;<=>?@]\\[^_`}|{~♥×" + "♡" + "←↑→↓";

	/**
	 * Other symbols we can render.
	 * These require special handling.
	 */
	public static var unicodeSymbols:String = "😠";

	/**
	 * Symbols which we are able to render in bold.
	 */
	public static var boldSymbols:String = " -*";

	/**
	 * Diacritic letters which we are able to render by adding the approprite diacritic symbol.
	 */
	public static var alphabetDiacritic:Map<String, String> = [
		"Á" => "A´",
		"á" => "a´",
		"É" => "E´",
		"é" => "e´",
		"Ó" => "O´",
		"ó" => "o´",
		"Ú" => "U´",
		"ú" => "u´",
	];

	/**
	 * Whether the given character can be rendered by this class.
	 */
	public static inline function isValid(character:String):Bool
	{
		return alphabetUpper.indexOf(character) != -1
			|| alphabetLower.indexOf(character) != -1
			|| numbers.indexOf(character) != -1
			|| validSymbol(character);
	}

	public static function validSymbol(character:String):Bool
	{
		return character == " " || symbols.indexOf8(character) != -1 || unicodeSymbols.indexOf8(character) != -1;
	}

	/**
	 * Set the y position of this character, in units.
	 */
	public var row:Int = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		loadSprite();
	}

	function loadSprite()
	{
		// Make sure to cache the `alphabet` sprite sheet
		var tex = GraphicsAssets.loadSparrowAtlas('alphabet', null, true);
		frames = tex;
		antialiasing = AntiAliasingOption.get();
	}

	public function createCharacter(letter:String, bold:Bool = false):Void
	{
		if (bold)
		{
			createBold(letter);
		}
		else if (alphabetUpper.indexOf(letter) != -1)
		{
			createLetterUpper(letter);
		}
		else if (alphabetLower.indexOf(letter) != -1)
		{
			createLetterLower(letter);
		}
		else if (AlphaCharacter.validSymbol(letter))
		{
			createSymbol(letter);
		}
		else if (numbers.indexOf(letter) != -1)
		{
			createNumber(letter);
		}
		else
		{
			Debug.logWarn('Warning: Alphabet does not understand character (got $letter)');
		}
	}

	function createBold(letter:String)
	{
		if (boldSymbols.indexOf(letter) != -1)
		{
			// Symbol that supports bold.
			createSymbol(letter, true);
			return;
		}
		else if (numbers.indexOf(letter) != -1)
		{
			// Number that does not support bold.
			Debug.logWarn('Warning: Alphabet does not support bold numbers (got $letter)');
			letter = "X";
		}
		else if (AlphaCharacter.validSymbol(letter))
		{
			// Symbol that does not support bold.
			Debug.logWarn('Warning: Alphabet does not support bold symbols (got $letter)');
			letter = "X";
		}
		else if (alphabetLower.indexOf(letter) != -1)
		{
			// Lowercase letters must be shifted to uppercase.
			letter = letter.toUpperCase();
		}

		// Play the corresponding animation for the letter.
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		updateHitbox();
	}

	function createLetterLower(letter:String):Void
	{
		animation.addByPrefix(letter, '$letter lowercase', 24);
		animation.play(letter);
		updateHitbox();

		y = (110 - height);
		y += row * 60;
	}

	function createLetterUpper(letter:String):Void
	{
		animation.addByPrefix(letter, '$letter uppercase', 24);
		animation.play(letter);
		updateHitbox();

		y = (110 - height);
		y += row * 60;
	}

	function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);
		updateHitbox();
	}

	function createSymbol(letter:String, ?bold:Bool = false)
	{
		var suffix = bold ? ' bold' : '';
		switch (letter)
		{
			case ' ': // U+0020
				animation.addByPrefix(letter, 'space', 24);
				animation.play(letter);
			case "!": // U+0021
				animation.addByPrefix(letter, '!$suffix', 24);
				animation.play(letter);
			case '"': // U+0022
				animation.addByPrefix(letter, '"$suffix', 24);
				animation.play(letter);
				y -= 0;
			case "#": // U+0023
				animation.addByPrefix(letter, '#$suffix', 24);
				animation.play(letter);
			case "$": // U+0024
				animation.addByPrefix(letter, '$$$suffix', 24);
				animation.play(letter);
			case "%": // U+0025
				animation.addByPrefix(letter, '%$suffix', 24);
				animation.play(letter);
			case "&": // U+0026
				animation.addByPrefix(letter, '&$suffix', 24);
				animation.play(letter);
			case "'": // U+0027
				animation.addByPrefix(letter, '\'$suffix', 24);
				animation.play(letter);
				y -= 0;
			case "(": // U+0028
				animation.addByPrefix(letter, '($suffix', 24);
				animation.play(letter);
			case ")": // U+0029
				animation.addByPrefix(letter, ')$suffix', 24);
				animation.play(letter);
			case "*": // U+002A
				animation.addByPrefix(letter, '*$suffix', 24);
				animation.play(letter);
			case "+": // U+002B
				animation.addByPrefix(letter, '+$suffix', 24);
				animation.play(letter);
			case ',': // U+002C
				animation.addByPrefix(letter, ',$suffix', 24);
				animation.play(letter);
				y += 50;
			case "-": // U+002D
				animation.addByPrefix(letter, '-$suffix', 24);
				animation.play(letter);
				y += 25;
			case '.': // U+002E
				animation.addByPrefix(letter, '.$suffix', 24);
				animation.play(letter);
				y += 50;
			case "/": // U+002F
				animation.addByPrefix(letter, '/$suffix', 24);
				animation.play(letter);
			case ":": // U+003A
				animation.addByPrefix(letter, ':$suffix', 24);
				animation.play(letter);
				y += 10;
			case ";": // U+003B
				animation.addByPrefix(letter, ';$suffix', 24);
				animation.play(letter);
			case "<": // U+003C
				animation.addByPrefix(letter, '<$suffix', 24);
				animation.play(letter);
			case "=": // U+003D
				animation.addByPrefix(letter, '=$suffix', 24);
				animation.play(letter);
				y += 15;
			case ">": // U+003E
				animation.addByPrefix(letter, '>$suffix', 24);
				animation.play(letter);
			case "?": // U+003F
				animation.addByPrefix(letter, '?$suffix', 24);
				animation.play(letter);
			case "@": // U+0040
				animation.addByPrefix(letter, '@$suffix', 24);
				animation.play(letter);
			case "[": // U+005B
				animation.addByPrefix(letter, '[$suffix', 24);
				animation.play(letter);
			case "\\": // U+005C
				animation.addByPrefix(letter, '/$suffix', 24);
				// LOL hacks
				animation.getByName(letter).flipY = true;
				animation.play(letter);
			case "]": // U+005D
				animation.addByPrefix(letter, ']$suffix', 24);
				animation.play(letter);
			case "^": // U+005E
				animation.addByPrefix(letter, '^$suffix', 24);
				animation.play(letter);
			case "_": // U+005F
				animation.addByPrefix(letter, '_$suffix', 24);
				animation.play(letter);
				y += 50;
			case "{": // U+007B
				animation.addByPrefix(letter, '{$suffix', 24);
				animation.play(letter);
			case "|": // U+007C
				animation.addByPrefix(letter, '|$suffix', 24);
				animation.play(letter);
				y += 25;
			case "}": // U+007D
				animation.addByPrefix(letter, '}$suffix', 24);
				animation.play(letter);
			case "~": // U+007E
				animation.addByPrefix(letter, '~$suffix', 24);
				animation.play(letter);
			case "×": // U+00D7
				animation.addByPrefix(letter, 'multiply x$suffix', 24);
				animation.play(letter);
			case '←': // U+2190
				animation.addByPrefix(letter, 'left arrow$suffix', 24);
				animation.play(letter);
			case '↑': // U+2191
				animation.addByPrefix(letter, 'up arrow$suffix', 24);
				animation.play(letter);
			case '→': // U+2192
				animation.addByPrefix(letter, 'right arrow$suffix', 24);
				animation.play(letter);
			case '↓': // U+2193
				animation.addByPrefix(letter, 'down arrow$suffix', 24);
				animation.play(letter);
			//			case '↔': // U+2194
			//				animation.addByPrefix(letter, 'left right arrow', 24);
			//				animation.play(letter);
			//			case '↕': // U+2195
			//				animation.addByPrefix(letter, 'up down arrow', 24);
			//				animation.play(letter);
			//			case '↖': // U+2196
			//				animation.addByPrefix(letter, 'north west arrow', 24);
			//				animation.play(letter);
			//			case '↗': // U+2197
			//				animation.addByPrefix(letter, 'north east arrow', 24);
			//				animation.play(letter);
			//			case '↘': // U+2198
			//				animation.addByPrefix(letter, 'south east arrow', 24);
			//				animation.play(letter);
			//			case '↙': // U+2199
			//				animation.addByPrefix(letter, 'south west arrow', 24);
			//				animation.play(letter);
			case '♥': // U+2665
				animation.addByPrefix(letter, 'heart$suffix', 24);
				animation.play(letter);
			case '♡':
				animation.addByPrefix(letter, 'heart$suffix', 24);
				animation.play(letter);
			// case '😠': // U+D83D
			// 	animation.addByPrefix(letter, 'angry face$suffix', 24);
			// 	animation.play(letter);
			default:
				Debug.logWarn('Warning: Alphabet does not understand symbol (got $letter)');
		}

		updateHitbox();
	}
}
