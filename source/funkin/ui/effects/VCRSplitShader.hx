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
 * VCRSplitShader.hx
 * [Module Description]
 */
package funkin.ui.effects;

import flixel.system.FlxAssets;

class ShaderShader extends FlxShader
{
	// https://www.shadertoy.com/view/Ms23DR
	@:glFragmentSource('
    #pragma header
    uniform float fade;
    
    void mainImage( out vec4 fragColor, in vec2 fragCoord )
    {
    	vec2 uv = fragCoord.xy / iResolution.xy;
      vec4 moviecol;
      vec2 uvOffset = texture(iChannel1, vec2(iTime*5.0)).rg;
      uvOffset.x *= 0.02;
      uvOffset.y *= 0.052;
      moviecol.r = texture(iChannel0, uv + uvOffset + vec2(-0.02*texture(iChannel1, vec2(uv.x,uv.y/200.0 + iTime*5.0)).r, (tan(sin(iTime)) * 0.6 ) * 0.05) ).r;
      moviecol.g = vec4(texture(iChannel0, uv + uvOffset)).g;
      moviecol.b = texture(iChannel0, uv / uvOffset + vec2(-0.01*texture(iChannel1, vec2(uv.x/2.0,uv.y + iTime*5.0)).r, -0.2) ).b;
      moviecol.rgb = mix(moviecol.rgb, vec3(dot(moviecol.rgb, vec3(.43))), 0.5);
    	fragColor = vec4(moviecol);
    }
    ')
	public function new()
	{
		super();
	}
}
