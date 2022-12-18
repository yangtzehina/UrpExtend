using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PlannarShadowRF : ScriptableRendererFeature
{
    class PlannarShadowPass : ScriptableRenderPass
    {
        private Material _material;

        public PlannarShadowPass(Material material)
        {
            this._material = material;
        }
        
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(name: "PlannarShadow");
            Camera camera = renderingData.cameraData.camera;
            
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }

    private PlannarShadowPass _plannarShadowPass;
    public Material material;
    public override void Create()
    {
        _plannarShadowPass = new PlannarShadowPass(material);
        _plannarShadowPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (material != null)
        {
            renderer.EnqueuePass(_plannarShadowPass);
        }
    }
}
