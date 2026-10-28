namespace ScomGroundMotion;

internal static class ForeignGroundProfiles
{
	internal static readonly Profile[] All = new Profile[4]
	{
		new Profile
		{
			MeshName = "wel0207_lod0",
			VertexCount = 2622,
			BindPoseCount = 11,
			Bands = new Band[4]
			{
				new Band
				{
					Vertices = Expand(new int[2] { 1080, 66 }),
					Axis = 0,
					UVPerMetre = 0.7704099f,
					CenterX = -0.340879f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[2] { 1014, 66 }),
					Axis = 0,
					UVPerMetre = 0.7704106f,
					CenterX = -0.34087887f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[2] { 2310, 66 }),
					Axis = 0,
					UVPerMetre = 0.7704106f,
					CenterX = 0.33930302f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[2] { 2376, 66 }),
					Axis = 0,
					UVPerMetre = 0.77040994f,
					CenterX = 0.33930317f,
					Period = 1f
				}
			}
		},
		new Profile
		{
			MeshName = "wel0309_lod0",
			VertexCount = 9570,
			BindPoseCount = 16,
			Bands = new Band[4]
			{
				new Band
				{
					Vertices = Expand(new int[4] { 1626, 30, 1680, 30 }),
					Axis = 0,
					UVPerMetre = 0.55443656f,
					CenterX = -0.33483475f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[4] { 1518, 30, 1572, 30 }),
					Axis = 0,
					UVPerMetre = 0.5544365f,
					CenterX = -0.33483475f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[4] { 1842, 30, 1896, 30 }),
					Axis = 0,
					UVPerMetre = 0.55443656f,
					CenterX = 0.33123162f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[4] { 1734, 30, 1788, 30 }),
					Axis = 0,
					UVPerMetre = 0.5544365f,
					CenterX = 0.33123162f,
					Period = 1f
				}
			}
		},
		new Profile
		{
			MeshName = "wel0401_lod0",
			VertexCount = 62031,
			BindPoseCount = 82,
			Bands = new Band[6]
			{
				new Band
				{
					Vertices = Expand(new int[4] { 16707, 6, 16773, 426 }),
					Axis = 0,
					UVPerMetre = 0.17198826f,
					CenterX = -2.3248756f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[4] { 17691, 6, 17757, 426 }),
					Axis = 0,
					UVPerMetre = 0.17198826f,
					CenterX = -2.1174204f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[4] { 17199, 6, 17265, 426 }),
					Axis = 0,
					UVPerMetre = 0.17198826f,
					CenterX = -2.1174204f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[4] { 18183, 6, 18249, 426 }),
					Axis = 0,
					UVPerMetre = 0.17198826f,
					CenterX = 2.1390228f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[4] { 18675, 6, 18741, 426 }),
					Axis = 0,
					UVPerMetre = 0.17198826f,
					CenterX = 2.1390228f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[4] { 19167, 6, 19233, 426 }),
					Axis = 0,
					UVPerMetre = 0.17198826f,
					CenterX = 2.346478f,
					Period = 1f
				}
			}
		},
		new Profile
		{
			MeshName = "wrl0309_lod0",
			VertexCount = 6660,
			BindPoseCount = 12,
			Bands = new Band[4]
			{
				new Band
				{
					Vertices = Expand(new int[2] { 2052, 36 }),
					Axis = 0,
					UVPerMetre = 0.8075633f,
					CenterX = -0.51751596f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[2] { 1992, 36 }),
					Axis = 0,
					UVPerMetre = 0.80756354f,
					CenterX = -0.5175158f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[2] { 2112, 36 }),
					Axis = 0,
					UVPerMetre = 0.8075636f,
					CenterX = 0.51754814f,
					Period = 1f
				},
				new Band
				{
					Vertices = Expand(new int[2] { 2172, 36 }),
					Axis = 0,
					UVPerMetre = 0.80756336f,
					CenterX = 0.51754844f,
					Period = 1f
				}
			}
		}
	};

	private static int[] Expand(int[] ranges)
	{
		int num = 0;
		for (int i = 1; i < ranges.Length; i += 2)
		{
			num += ranges[i];
		}
		int[] array = new int[num];
		int num2 = 0;
		for (int j = 0; j < ranges.Length; j += 2)
		{
			for (int k = 0; k < ranges[j + 1]; k++)
			{
				array[num2++] = ranges[j] + k;
			}
		}
		return array;
	}
}
