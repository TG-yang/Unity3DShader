
Shader "Custom/Ramp Texture" {

	Properties{

		_Color("Color",Color)=(1,1,1,1)
		_RampTex("Ramp Tex",2D)="white"{}
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8.0,256))=20
		}

	Subshader{

		Pass{

			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
			};

			v2f vert(a2v v){

				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex);
				o.uv=TRANSFORM_TEX(v.texcoord,_RampTex);
				o.worldNormal=UnityObjectToWorldNormal(v.normal);

				return o;
			}

			fixed4 frag(v2f i):SV_Target{

				fixed3 worldNormal=normalize(i.worldNormal);
				fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed halfLambet=0.5*dot(worldNormal,worldLightDir)+0.5;
				fixed3 diffuseColor=tex2D(_RampTex,fixed2(halfLambet,halfLambet)).rgb*_Color.rgb;
				fixed3 diffuse=_LightColor0.rgb*diffuseColor;

				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 halfDir=normalize(worldLightDir+worldViewDir);
				fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);

				return fixed4(specular+diffuse+ambient,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}
