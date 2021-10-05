package funkin.ui.component.modding;

import flixel.addons.ui.FlxUIButton;
import flixel.math.FlxPoint;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIText;
import flixel.FlxSprite;
import flixel.text.FlxText;
import funkin.ui.component.input.InteractableUIGroup;
import openfl.geom.Rectangle;
import polymod.Polymod.ModMetadata;

class ModListItem extends InteractableUIGroup
{
	static final BG_X:Float = 5;
	static final BG_Y:Float = 5;
	// 480px wide
	static final BG_W:Float = 480;
	// 120px tall
	static final BG_H:Float = 110;

	// 10px from left side
	static final ICON_X:Float = BG_X + 5;
	// 10px from tip side
	static final ICON_Y:Float = BG_Y + 5;
	// 100px by 100px
	static final ICON_SCALE:Int = 100;

	static final ICON_LOADED_OFFSET:Float = 20;

	// 10 px to right of icon.
	static final TITLE_X:Float = ICON_X + ICON_SCALE + 10;
	// 20 px below top of box.
	static final TITLE_Y:Float = BG_Y + 5;
	// 16pt font
	static final TITLE_SCALE:Int = 20;

	// Only allow between the start and 10px from the end.
	// Force to wrap otherwise.
	static final TEXT_WIDTH:Float = BG_W - TITLE_X - 16 - 5;

	static final DESC_X:Float = TITLE_X;
	static final DESC_Y:Float = TITLE_Y + 25;
	static final DESC_SCALE:Int = 12;

	static final BUTTON_X_RIGHT:Float = BG_W - 20;
	static final BUTTON_X_LEFT:Float = 5;
	static final BUTTON_Y:Float = BG_Y + 24;
	static final BUTTON_OFFSET:Float = 20;

	public var modId(default, null):String;

	var modMetadata(default, null):ModMetadata;

	var loaded(default, set):Bool;

	function set_loaded(newValue:Bool)
	{
		this.loaded = newValue;
		onChangeLoaded();
		return this.loaded;
	}

	// UI
	var uiBackground:FlxUI9SliceSprite;
	var uiTitle:FlxText;
	var uiDescription:FlxText;
	var uiIcon:FlxSprite;

	// Button to activate mod.
	var uiButtonRight:FlxUIButton;

	// Button to deactivate mod.
	var uiButtonLeft:FlxUIButton;

	// Button to reorder mod.
	var uiButtonUp:FlxUIButton;
	var uiButtonDown:FlxUIButton;

	public function new(modMetadata:ModMetadata, X:Float = 0, Y:Float = 0, loaded:Bool = false)
	{
		super(X, Y);

		this.modId = modMetadata.id;
		this.modMetadata = modMetadata;

		this.name = this.modId;

		buildLayout();

		this.loaded = loaded;
	}

	override function initVars():Void
	{
		super.initVars();
	}

	function buildLayout()
	{
		this.uiBackground = new FlxUI9SliceSprite(BG_X, BG_Y, FlxUIAssets.IMG_CHROME, new Rectangle(BG_X, BG_Y, BG_W, BG_H));
		this.uiTitle = new FlxUIText(TITLE_X, TITLE_Y, TEXT_WIDTH, this.modMetadata.title, TITLE_SCALE);
		this.uiDescription = new FlxUIText(DESC_X, DESC_Y, TEXT_WIDTH, this.modMetadata.description, DESC_SCALE);
		this.uiDescription.wordWrap = true;
		add(this.uiBackground);
		add(this.uiTitle);
		add(this.uiDescription);

		buildButtons();

		loadIcon(modMetadata.icon);

		this.scrollFactor.set(1, 1);
	}

	function buildButtonIcons()
	{
	}

	function buildButtons()
	{
		this.uiButtonUp = new FlxUIButton(BUTTON_X_LEFT, BUTTON_Y, null, onUserReorderMod.bind(-1));
		this.uiButtonUp.loadGraphicsUpOverDown(FlxUIAssets.IMG_BUTTON_ARROW_UP);

		var BUTTON_MIDDLE_OFFSET = BUTTON_Y + BUTTON_OFFSET;

		this.uiButtonLeft = new FlxUIButton(BUTTON_X_LEFT, BUTTON_MIDDLE_OFFSET, null, onUserLoadMod.bind());
		this.uiButtonLeft.loadGraphicsUpOverDown(FlxUIAssets.IMG_BUTTON_ARROW_LEFT);

		this.uiButtonRight = new FlxUIButton(BUTTON_X_RIGHT, BUTTON_MIDDLE_OFFSET, null, onUserUnloadMod.bind());
		this.uiButtonRight.loadGraphicsUpOverDown(FlxUIAssets.IMG_BUTTON_ARROW_RIGHT);

		var BUTTON_BOTTOM_OFFSET = BUTTON_MIDDLE_OFFSET + BUTTON_OFFSET;

		this.uiButtonDown = new FlxUIButton(BUTTON_X_LEFT, BUTTON_BOTTOM_OFFSET, null, onUserReorderMod.bind(1));
		this.uiButtonDown.loadGraphicsUpOverDown(FlxUIAssets.IMG_BUTTON_ARROW_DOWN);

		add(this.uiButtonUp);
		add(this.uiButtonLeft);
		add(this.uiButtonRight);
		add(this.uiButtonDown);

		// Automatically triggered by constructor.
		// onChangeLoaded();
	}

	function onChangeLoaded()
	{
		// If unloaded, show load button.
		this.uiButtonRight.visible = !this.loaded;

		// If loaded, show unload and reorder buttons.
		this.uiButtonUp.visible = this.loaded;
		this.uiButtonLeft.visible = this.loaded;
		this.uiButtonDown.visible = this.loaded;

		// Nudge the content to the left to make space for the buttons.
		var offset = this.loaded ? ICON_LOADED_OFFSET : 0;
		this.uiIcon.x = ICON_X + offset;
		this.uiTitle.x = TITLE_X + offset;
		this.uiDescription.x = DESC_X + offset;
	}

	function onUserLoadMod()
	{
		this.loaded = !this.loaded;
	}

	function onUserUnloadMod()
	{
		this.loaded = !this.loaded;
	}

	function onUserReorderMod(offset:Int)
	{
	}

	function loadIcon(bytes:haxe.io.Bytes)
	{
		// Convert a haxe byte array to the proper data structure.
		var future = openfl.utils.ByteArray.loadFromBytes(bytes);

		future.onComplete(function(openFlBytes:openfl.utils.ByteArray)
		{
			trace('Loaded icon bytes for mod ${modId}.');
			// Convert the bytes into bitmap data.
			var bitmapData = openfl.display.BitmapData.fromBytes(openFlBytes);
			// Tie the bitmap data to a sprite.
			uiIcon = new FlxUISprite(ICON_X, ICON_Y).loadGraphic(bitmapData);
			uiIcon.setGraphicSize(ICON_SCALE, ICON_SCALE);
			uiIcon.scrollFactor.set();
			uiIcon.antialiasing = true;
			uiIcon.updateHitbox();
			uiIcon.scrollFactor.set();

			add(uiIcon);
		});
		future.onError(function(error)
		{
			trace(error);
		});
	}
}
