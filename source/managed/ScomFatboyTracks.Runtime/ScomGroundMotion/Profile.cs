namespace ScomGroundMotion;

internal sealed class Profile
{
	public string MeshName;

	public int VertexCount;

	public int BindPoseCount;

	public Band[] Bands;

	public string[] TextureProperties = new string[3] { "_MainTex", "_NormalMap", "_MaskMap" };

	public TextureQuality[] TextureQuality = new TextureQuality[0];
}
