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
