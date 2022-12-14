Shader "ShadowExtend/PlannerShadow"
{
	Properties
	{
		
	}
	SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" }

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

            float3 ShadowProjectPos(float4 vertPos)
	        {
		        float3 shadowPos;

		        //得到顶点的世界空间坐标
		        float3 worldPos = mul(unity_ObjectToWorld , vertPos).xyz;

		        //灯光方向
		        float3 lightDir = normalize(GetMainLight().direction);

		        //阴影的世界空间坐标（低于地面的部分不做改变）
		        shadowPos.y = min(worldPos.y , 0);
		        shadowPos.xz = worldPos .xz - lightDir.xz * max(0 , worldPos .y) / lightDir.y; 

		        return shadowPos;
	        }

            Varyings vert (Attributes IN)
            {
                Varyings  OUT;
                //得到阴影的世界空间坐标
		        float3 shadowPos = ShadowProjectPos(IN.positionOS);

		        //转换到裁切空间
		        OUT.positionCS = TransformWorldToHClip(shadowPos);

		        //得到中心点世界坐标
		        float3 center =float3( unity_ObjectToWorld[0].w , 0 , unity_ObjectToWorld[2].w);
		        //计算阴影衰减
		        float falloff = 1-saturate(distance(shadowPos , center) * 1);

		        //阴影颜色
		        OUT.color = unity_ShadowColor; 
		        OUT.color.a *= falloff;
                
                return OUT;
            }

            half4 frag (Varyings  input) : SV_Target
            {
                return input.color;
            }

            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
