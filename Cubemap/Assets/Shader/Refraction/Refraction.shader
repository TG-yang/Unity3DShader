Shader "Custome/Refraction" {
	Properties{

		_Color("Color Tint",Color)=(1,1,1,1)
		_RefractColor("Refraction Color",Color)=(1,1,1,1)
		_RefractAmount("Refraction Amount",Range(0,1))=1
		_RefractRadio("Refraction Audio",Range(0.1,1))=0.5
		_Cubemap("Refraction Cubemap",Cube)="_Skybox"{}
	}

	Subshader{

		Tags{"RenderType"="Opaque" "Queue"="Geometry"}

		Pass{

			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include"Lighting.cginc"
			#include"AutoLight.cginc"

			fixed4 _Color;
			fixed4 _RefractColor;
			float _RefractAmount;
			fixed _RefractRadio;
			samplerCUBE _Cubemap;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				fixed3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				fixed3 worldView:TEXCOORD2;
				fixed3 worldRefract:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v){

				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldView=UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefract=refract(-normalize(o.worldView), normalize(o.worldNormal), _RefractRadio);
				TRANSFER_SHADOW(o);

				return o;
			}


			fixed4 frag(v2f i):SV_Target{

				fixed3 worldNormal=normalize(i.worldNormal);
				fixed3 worldView=normalize(i.worldView);
				fixed3 worldLight=normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse=_LightColor0.rgb*_Color.rgb*max(0,dot(worldNormal,worldLight));

				fixed3 refraction=texCUBE(_Cubemap,i.worldRefract).rgb*_RefractColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				fixed3 color=ambient+lerp(diffuse,refraction,_RefractAmount)*atten;

				return fixed4(color,1.0);

				//fixed3 worldNormal = normalize(i.worldNormal);
				//fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				//fixed3 worldViewDir = normalize(i.worldView);
								
				//fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				//fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
				
				// Use the refract dir in world space to access the cubemap
				//fixed3 refraction = texCUBE(_Cubemap, i.worldRefract).rgb * _RefractColor.rgb;
				
				//UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				
				// Mix the diffuse color with the refract color
				//fixed3 color = ambient + lerp(diffuse, refraction, _RefractAmount) * atten;
				
				//return fixed4(color, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Reflective/VertexLit"
}
