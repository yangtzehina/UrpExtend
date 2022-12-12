Shader "ShadowExtend/PlannerShadow"
{
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Geometry" }

        Pass
        {
            Name "PlannarShadow"

            //用使用模板测试以保证alpha显示正确
	        Stencil
	        {
		        Ref 0
		        Comp equal
		        Pass incrWrap
		        Fail keep
		        ZFail keep
	        }
            //透明混合模式
            Blend SrcAlpha OneMinusSrcAlpha
            //关闭深度写入
            ZWrite Off
            //深度偏移，高于地面
            Offset -1,0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes 
            {
                float4 positionOS : POSITION;
            };

            struct Varyings 
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
            };

            Varyings vert (Attributes IN)
            {
                Varyings  OUT;
                //得到阴影的世界空间坐标
		        float3 shadowPos = ShadowProjectPos(IN.positionOS);

		        //转换到裁切空间
		        OUT.vertex = TransformWorldToHClip(shadowPos);

		        //得到中心点世界坐标
		        float3 center =float3( unity_ObjectToWorld[0].w , _LightDir.w , unity_ObjectToWorld[2].w);
		        //计算阴影衰减
		        float falloff = 1-saturate(distance(shadowPos , center) * _ShadowFalloff);

		        //阴影颜色
		        OUT.color = _ShadowColor; 
		        OUT.color.a *= falloff;
                
                return OUT;
            }

            half4 frag (Varyings  input) : SV_Target
            {
                return input.color;
            }

            float3 ShadowProjectPos(float4 vertPos)
	        {
		        float3 shadowPos;

		        //得到顶点的世界空间坐标
		        float3 worldPos = mul(unity_ObjectToWorld , vertPos).xyz;

		        //灯光方向
		        float3 lightDir = normalize(_LightDir.xyz);

		        //阴影的世界空间坐标（低于地面的部分不做改变）
		        shadowPos.y = min(worldPos .y , _LightDir.w);
		        shadowPos.xz = worldPos .xz - lightDir.xz * max(0 , worldPos .y - _LightDir.w) / lightDir.y; 

		        return shadowPos;
	        }

            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
