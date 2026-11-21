using EM.Map;
using UnityEngine;

namespace ScomShatter
{
    // Snapshot on the Unity thread; freeze can change while the map is loaded.
    internal struct MapWater
    {
        internal readonly bool HasWater;
        internal readonly float WorldLevel;
        internal readonly float FreezeAmount;

        private MapWater(bool hasWater, float worldLevel, float freezeAmount)
        {
            HasWater = hasWater;
            WorldLevel = worldLevel;
            FreezeAmount = freezeAmount;
        }

        internal bool IsFullyFrozen => HasWater && FreezeAmount >= 1f;

        // WorldLevel and siteY share world coordinates, including the terrain origin.
        internal float RelativeLevel(float siteY) => WorldLevel - siteY;

        internal bool CoversTerrain(float terrainWorldY) => HasWater && terrainWorldY < WorldLevel;

        internal static bool TryCapture(out MapWater water)
        {
            water = default(MapWater);
            if (!MapManager.IsMapLoadedForClient || MapManager.mapFile == null)
                return false;

            var map = MapManager.mapFile;
            if (!map.hasWater)
            {
                water = new MapWater(false, 0f, 0f);
                return true;
            }

            float level = map.waterLevel;
            float freezing = Shader.GetGlobalFloat("_WaterFreezing");
            if (float.IsNaN(level) || float.IsInfinity(level) ||
                float.IsNaN(freezing) || float.IsInfinity(freezing))
                return false;
            water = new MapWater(true, level, Mathf.Clamp01(freezing));
            return true;
        }
    }
}
