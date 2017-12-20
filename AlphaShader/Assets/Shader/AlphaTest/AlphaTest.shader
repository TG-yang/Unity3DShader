Shader "Custom/Alpha Test" {

	Properties{

		_MainTex("Main Tex",2D)="whilte"{}
		_Color("Color",Color)=(1,1,1,1)
		_Cutoff("Alpht Cutoff",Range(0,1))=0.5
	}

	Subshader{

		Tags{"Queue"="AlphaTest" "IgnoreProjector"="true" "RenderType"="TransparentCutout"}

		Pass{

			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _Cutoff;

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
				o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			fixed4 frag(v2f i):SV_Target{

			fixed3 worldNormal=normalize(i.worldNormal);
			fixed3 worldLight=normalize(UnityWorldSpaceLightDir(i.worldPos));
			fixed4 texColor=tex2D(_MainTex,i.uv);

			clip(texColor.a-_Cutoff);

			fixed3 albedo=texColor.rgb*_Color.rgb;
			fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
			fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLight));

			return fixed4(diffuse+ambient,1.0);
			}

			ENDCG
		}
	}


	FallBack "Transparent/Cutout/VertexLit"
}
