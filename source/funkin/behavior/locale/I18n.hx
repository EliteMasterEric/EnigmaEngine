/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * I18n.hx
 * Functionality to translate text. Powered by FireTongue.
 */
package funkin.behavior.localization;

import firetongue.FireTongue;

class I18n
{
	static final DEFAULT_LOCALE = 'en-US';
	static var tongue:FireTongue;

	public static function initLocalization(locale:String = 'en-US')
	{
		tongue = new FireTongue();
	}

	/**
	 * Fetch a string by its translation key.
	 * @param key 
	 */
	public static function t(key:String, ns:String = 'data')
	{
		var result = tongue.get(key, ns);
		trace('Translate: $ns:$key -> "$result"');
	}

	/**
	 * `<Q>`  = Standard single quotation mark ( " )
	 * `<LQ>` = Fancy left quotation mark ( “ )
	 * `<RQ>` = Fancy right quotation mark ( ” )
	 * `<C>`  = Standard comma
	 * `<N>`  = Line break
	 * `<T>`  = Tab
	 */
}
