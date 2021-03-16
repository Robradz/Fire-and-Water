// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Shaders/ChangeTex"
{
	Properties
	{
		_Color("Color1", Color) = (1,1,1,1)
		_Tex1("Texture", 2D) = "white" {}
		_Tex2("Texture", 2D) = "black" {}
		_Bump1("Normal Map", 2D) = "white" {}
		_Bump2("Normal Map", 2D) = "white" {}
		_Emission1("Emission Map", 2D) = "white" {}
		_Emission2("Emission Map", 2D) = "white" {}
		_Speed("Speed", Range(-200,200)) = 100
		_Strength("Waveyness", Range(0, 10)) = 2
		_Range_UV("Uv", float) = 1
		_MainLightPosition("MainLightPosition", Vector) = (0,0,0,0)
		_SSx("Scroll Speed x", float) = 0
		_SSy("Scroll Speed y", float) = 0
	}

		SubShader
	{
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		ZWrite On
		//Blend SrcAlpha OneMinusSrcAlpha
		Blend One OneMinusSrcAlpha
		LOD 100

		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert alpha// Pragma is a compiler directive
			#pragma fragment frag alpha// Vertex/fragment is the command, vert/frag are hte names of our functions

			sampler2D _Tex1;
			sampler2D _Tex2;
			sampler _Bump1;
			sampler _Bump2;
			float4 _Color;
			float _Speed;
			float _Strength;
			float _Range_UV;
			float3 _MainLightPosition;
			float4 _LightColor0;
			sampler _Emission1;
			sampler _Emission2;
			float _SSx;
			float _SSy;


			struct VertexShaderInput
			{
				float4 position: POSITION;
				float2 uv      : TEXCOORD0;

				float3 normal  : NORMAL;
				float3 tangent : TANGENT;
			};

			struct VertexShaderOutput
			{
				float4 position : POSITION;
				float2 uv       : TEXCOORD0;
				float3 lightdir : TEXCOORD1;
				float3 viewdir  : TEXCOORD2;

				float3 T : TEXCOORD3;
				float3 B : TEXCOORD4;
				float3 N : TEXCOORD5;
			};

			VertexShaderOutput vert(VertexShaderInput v) // v is input data coming from Unity
			{
				VertexShaderOutput o;
				o.uv = v.uv;
				o.position = UnityObjectToClipPos(v.position);

				// calc lightDir vector heading current vertex
				float4 worldPosition = mul(unity_ObjectToWorld, v.position);
				float3 lightDir = worldPosition.xyz - _MainLightPosition.xyz;
				o.lightdir = normalize(lightDir);

				// calc viewDir vector 
				float3 viewDir = normalize(worldPosition.xyz - _WorldSpaceCameraPos.xyz);
				o.viewdir = viewDir;

				float3 worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);
				float3 worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent);

				float3 binormal = cross(v.normal, v.tangent.xyz); // *input.tangent.w;
				float3 worldBinormal = mul((float3x3)unity_ObjectToWorld, binormal);

				o.N = normalize(worldNormal);
				o.T = normalize(worldTangent);
				o.B = normalize(worldBinormal);
				
				return o;
			}

			float4 frag(VertexShaderOutput i) :SV_TARGET // fragment shader, i holds input coming from vertex shader 
			{
				float timer = (cos(_Time * 5) + .75) / 1.5;
				_Range_UV = timer;
				float4 output;
				fixed xScroll = _SSx * _Time;
				fixed yScroll = _SSy * _Time;

				if (i.uv.x > timer) {
					fixed2 scrolledUV = i.uv + fixed2(xScroll, yScroll);

					// The normal map requires the tangent of each point in order to decide the normal
					// i.N = world normal
					// i.T = world tangent
					// i.B = world binormal
					float3 tangentNormal = tex2D(_Bump1, scrolledUV).xyz;
					tangentNormal = normalize(tangentNormal * 2 - 1);
					float3x3 TBN = float3x3(normalize(i.T), normalize(i.B), normalize(i.N));
					TBN = transpose(TBN);

					float3 worldNormal = mul(TBN, tangentNormal);

					float4 albedo = tex2D(_Tex1, scrolledUV);
					float3 lightDir = normalize(i.lightdir);

					// Uses the normal map to make the diffuse reflect light correctly
					float3 diffuse = saturate(dot(worldNormal, -lightDir));
					diffuse = _LightColor0 * albedo.rgb * diffuse;

					float3 ambient = float3(0.1f, 0.1f, 0.1f) * 3 * albedo;

					float4 emission = tex2D(_Emission1, scrolledUV);
					output = float4(ambient + diffuse, 1) + emission;
					output = float4(output.xyz, 0.6);
					return output;
				}
				else {
					fixed2 scrolledUV = i.uv + fixed2(xScroll, yScroll);
					float3 tangentNormal = tex2D(_Bump2, scrolledUV).xyz;
					tangentNormal = normalize(tangentNormal * 2 - 1);
					float3x3 TBN = float3x3(normalize(i.T), normalize(i.B), normalize(i.N));
					TBN = transpose(TBN);

					float3 worldNormal = mul(TBN, tangentNormal);

					float4 albedo = tex2D(_Tex2, scrolledUV);
					float3 lightDir = normalize(i.lightdir);

					float3 diffuse = saturate(dot(worldNormal, -lightDir));
					diffuse = _LightColor0 * albedo.rgb * diffuse;

					float3 ambient = float3(0.1f, 0.1f, 0.1f) * 3 * albedo;

					float4 emission = tex2D(_Emission2, scrolledUV);
					return float4(ambient + diffuse, 1) + emission;
				}
			}

			ENDCG
		}
	}
}
