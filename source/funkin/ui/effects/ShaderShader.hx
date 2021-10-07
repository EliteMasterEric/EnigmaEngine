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
 * ShaderShader.hx
 * [Module Description]
 */
package funkin.behavior;

import flixel.system.FlxAssets;

class ShaderShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header
    uniform float fade;
    
    varying vec4 color;
    varying vec2 textureCoord;
    varying vec2 textureSize;
    uniform sampler2D sampler0;
    
    float luma(vec3 color) {
        return dot(color, vec3(0.299, 0.587, 0.114));
    }
    
    vec3 rgb(float r, float g, float b) {
        return vec3(r/255.0,g/255.0,b/255.0);
    }
    
    void main()
    {
        vec2 uv = textureCoord;
        
        vec3 col = texture2D( sampler0, uv ).rgb;
        float bright=floor(luma(col+0.4)*4.0)/4.0;
        
        vec3 newcol;
        if (bright<0.3) newcol = 	  rgb(54.0,87.0,53.0);
        else if (bright<0.6) newcol = rgb(128.0,128.0,0.0);
        else newcol = 				  rgb(157.0,187.0,97.0);
        gl_FragColor = vec4( newcol*(fade)+col*(1.0-fade), 1.0 ) * color;
    }
    ')
	public function new()
	{
		super();
	}
}
