Shader "Custome/Reflection" {
	Properties{

		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_ReflectColor("Refect Color",Color)=(1,1,1,1)
		_ReflectAmount("Reflect Amount",Range(0,1))=1
		_Cubemap("Reflection Cubemap",Cube)="_Skybox"{}
		}

		Subshader{

			Tags{"RanderType"="Opaque" "Queue"="Geometry"}

			Pass{

				Tags { "LightMode"="ForwardBase" }
			
				CGPROGRAM
			
				#pragma multi_compile_fwdbase
			
				#pragma vertex vert
				#pragma fragment frag
			
				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				fixed4 _Color;
				fixed4 _ReflectColor;
				fixed _ReflectAmount;
				samplerCUBE _Cubemap;

				struct a2v{
					float4 vertex:POSITION;
					float3 normal:NORMAL;
				};

				struct v2f{
					float4 pos:SV_POSITION;
					float3 worldPos:TEXCOORD0;
					fixed3 worldView:TEXCOORD1;
					fixed3 worldNormal:TEXCOORD2;
					fixed3 worldReflect:TEXCOORD3;
					SHADOW_COORDS(4)
				};

				v2f vert(a2v v){

					v2f o;
					o.pos=UnityObjectToClipPos(v.vertex);
					o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
					o.worldView=UnityWorldSpaceViewDir(v.vertex);
					o.worldNormal=UnityObjectToWorldNormal(v.vertex);
					o.worldReflect=reflect(-o.worldView,o.worldNormal);

					TRANSFER_SHADOW(o);

					return o;
				}

				fixed4 frag(v2f i):SV_Target{

					fixed3 worldNormal=normalize(i.worldNormal);
					fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 worldView=normalize(i.worldView);

					fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;

					fixed3 diffuse=_LightColor0.rgb*_Color.rgb*max(0,dot(worldNormal,worldLightDir));

					fixed3 reflection=texCUBE(_Cubemap,i.worldReflect).rgb*_ReflectColor.rgb;

					UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

					fixed3 color=ambient+lerp(diffuse,reflection,_ReflectAmount)*atten;

					return fixed4(color,1.0);
				}

				ENDCG
			}
		}
			FallBack "Reflective/VertexLit"
}
