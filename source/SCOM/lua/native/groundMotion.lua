-- Editable SCOM track metadata. Restart the game after changes.
-- Data-only Lua: return a table of strings, finite numbers, and tables; no expressions/functions.
-- ranges is a flat sequence of zero-based vertex start/count pairs; uvPerMetre controls track speed.
-- Only SCOM profiles belong here. Wyvern profiles remain owned by their existing native fallback.
return {
    version = 1,
    textureProperties = { "_MainTex", "_NormalMap", "_MaskMap" },
    profiles = {
        {
            mesh = "ucl1101_lod0", vertexCount = 2238, bindPoseCount = 7,
            bands = {
                { ranges = { 174, 12, 210, 24, 330, 24 }, axis = 0, uvPerMetre = 0.8417357, centerX = -0.12553717, period = 1 },
                { ranges = { 120, 36, 294, 12, 318, 12 }, axis = 0, uvPerMetre = 0.8417357, centerX = 0.12553717, period = 1 },
            },
        },
        {
            mesh = "ucl2002_lod0", vertexCount = 2052, bindPoseCount = 13,
            bands = {
                { ranges = { 2004, 36 }, axis = 0, uvPerMetre = 0.57764363, centerX = -0.2605, period = 1 },
                { ranges = { 1446, 36 }, axis = 0, uvPerMetre = 0.5776422, centerX = 0.26045343, period = 1 },
            },
        },
        {
            mesh = "uel1001_lod0", vertexCount = 1407, bindPoseCount = 7,
            bands = {
                { ranges = { 684, 24 }, axis = 0, uvPerMetre = 2.832033, centerX = -0.18344355, period = 1 },
                { ranges = { 615, 18 }, axis = 0, uvPerMetre = 2.3521717, centerX = -0.18006127, period = 1 },
                { ranges = { 666, 18 }, axis = 0, uvPerMetre = 2.3521717, centerX = 0.18006127, period = 1 },
                { ranges = { 642, 24 }, axis = 0, uvPerMetre = 2.832033, centerX = 0.18344355, period = 1 },
            },
        },
        {
            mesh = "uel1101_lod0", vertexCount = 1596, bindPoseCount = 23,
            bands = {
                { ranges = { 822, 24 }, axis = 0, uvPerMetre = 2.5992484, centerX = -0.13888903, period = 1 },
                { ranges = { 846, 30 }, axis = 0, uvPerMetre = 2.5992482, centerX = -0.13888901, period = 1 },
                { ranges = { 804, 18 }, axis = 0, uvPerMetre = 2.599249, centerX = -0.13888901, period = 1 },
                { ranges = { 654, 6 }, axis = 0, uvPerMetre = 2.5992484, centerX = -0.13888901, period = 1 },
                { ranges = { 876, 30 }, axis = 0, uvPerMetre = 2.5992496, centerX = 0.13871294, period = 1 },
                { ranges = { 741, 18 }, axis = 0, uvPerMetre = 2.599249, centerX = 0.13871294, period = 1 },
                { ranges = { 690, 6 }, axis = 0, uvPerMetre = 2.5992496, centerX = 0.13871294, period = 1 },
                { ranges = { 906, 24 }, axis = 0, uvPerMetre = 2.5992503, centerX = 0.13871294, period = 1 },
            },
        },
        {
            mesh = "uel1201_lod0", vertexCount = 1395, bindPoseCount = 10,
            bands = {
                { ranges = { 783, 30 }, axis = 0, uvPerMetre = -3.2716484, centerX = -0.14449576, period = 1 },
                { ranges = { 753, 30 }, axis = 0, uvPerMetre = 3.2716463, centerX = -0.14449574, period = 1 },
                { ranges = { 432, 30 }, axis = 0, uvPerMetre = 3.2716458, centerX = 0.14449574, period = 1 },
                { ranges = { 402, 30 }, axis = 0, uvPerMetre = -3.2716484, centerX = 0.14449576, period = 1 },
            },
        },
        {
            mesh = "uel1501_lod0", vertexCount = 1560, bindPoseCount = 13,
            bands = {
                { ranges = { 570, 66 }, axis = 0, uvPerMetre = 1.0866199, centerX = -0.208125, period = 1 },
                { ranges = { 420, 66 }, axis = 0, uvPerMetre = 1.0866199, centerX = 0.2081067, period = 1 },
            },
        },
        {
            mesh = "uel1701_lod0", vertexCount = 918, bindPoseCount = 6,
            bands = {
                { ranges = { 438, 48 }, axis = 0, uvPerMetre = 2.318087, centerX = -0.00015544519, period = 1 },
                { ranges = { 486, 48 }, axis = 0, uvPerMetre = 1.3539152, centerX = -0.00015541539, period = 1 },
            },
        },
        {
            mesh = "uel2201_lod0", vertexCount = 2037, bindPoseCount = 11,
            bands = {
                { ranges = { 849, 42 }, axis = 0, uvPerMetre = 1.9950117, centerX = -0.22983958, period = 1 },
                { ranges = { 933, 42 }, axis = 0, uvPerMetre = 1.9950119, centerX = -0.22983956, period = 1 },
                { ranges = { 891, 42 }, axis = 0, uvPerMetre = 1.9950106, centerX = -0.22983955, period = 1 },
                { ranges = { 807, 42 }, axis = 0, uvPerMetre = 1.9950092, centerX = -0.22983955, period = 1 },
                { ranges = { 573, 42 }, axis = 0, uvPerMetre = 1.9950117, centerX = -0.22983953, period = 1 },
                { ranges = { 396, 42 }, axis = 0, uvPerMetre = 1.9950113, centerX = 0.23069558, period = 1 },
                { ranges = { 1017, 42 }, axis = 0, uvPerMetre = 1.995012, centerX = 0.23069558, period = 1 },
                { ranges = { 975, 42 }, axis = 0, uvPerMetre = 1.9950125, centerX = 0.23069558, period = 1 },
                { ranges = { 447, 42 }, axis = 0, uvPerMetre = 1.9950128, centerX = 0.2306956, period = 1 },
                { ranges = { 510, 42 }, axis = 0, uvPerMetre = 1.9950135, centerX = 0.2306956, period = 1 },
            },
        },
        {
            mesh = "uel2501_lod0", vertexCount = 2808, bindPoseCount = 15,
            bands = {
                { ranges = { 450, 60 }, axis = 0, uvPerMetre = 2.0757468, centerX = -0.2604799, period = 1 },
                { ranges = { 510, 66 }, axis = 0, uvPerMetre = 0.9455435, centerX = -0.25703698, period = 1 },
                { ranges = { 1614, 66 }, axis = 0, uvPerMetre = 0.94554365, centerX = 0.25704002, period = 1 },
                { ranges = { 1680, 60 }, axis = 0, uvPerMetre = 2.0757482, centerX = 0.26048, period = 1 },
            },
        },
        {
            mesh = "uel3002_lod0", vertexCount = 2223, bindPoseCount = 8,
            bands = {
                { ranges = { 909, 30 }, axis = 0, uvPerMetre = 0.7392487, centerX = -0.22374229, period = 1 },
                { ranges = { 861, 36 }, axis = 0, uvPerMetre = 0.9360866, centerX = -0.22374228, period = 1 },
                { ranges = { 813, 6, 951, 30 }, axis = 0, uvPerMetre = 0.9360866, centerX = 0.22374228, period = 1 },
                { ranges = { 981, 30 }, axis = 0, uvPerMetre = 0.7392487, centerX = 0.22374229, period = 1 },
            },
        },
        {
            mesh = "uel3101_lod0", vertexCount = 3399, bindPoseCount = 34,
            bands = {
                { ranges = { 126, 6, 918, 102 }, axis = 0, uvPerMetre = 0.84446114, centerX = -0.29920787, period = 1 },
                { ranges = { 114, 12, 738, 132 }, axis = 0, uvPerMetre = 0.9065457, centerX = -0.2752916, period = 1 },
                { ranges = { 195, 144 }, axis = 0, uvPerMetre = 0.9065457, centerX = 0.27008653, period = 1 },
                { ranges = { 339, 6, 411, 102 }, axis = 0, uvPerMetre = 0.84446114, centerX = 0.2940028, period = 1 },
            },
        },
        {
            mesh = "uel3501_lod0", vertexCount = 4116, bindPoseCount = 16,
            bands = {
                { ranges = { 1266, 60 }, axis = 0, uvPerMetre = 1.6605982, centerX = -0.3256, period = 1 },
                { ranges = { 1206, 60 }, axis = 0, uvPerMetre = 1.6605978, centerX = -0.32559997, period = 1 },
                { ranges = { 1140, 66 }, axis = 0, uvPerMetre = 0.7564349, centerX = -0.32129616, period = 1 },
                { ranges = { 630, 66 }, axis = 0, uvPerMetre = 0.756435, centerX = 0.3213, period = 1 },
                { ranges = { 756, 60 }, axis = 0, uvPerMetre = 1.6605978, centerX = 0.32559997, period = 1 },
                { ranges = { 696, 60 }, axis = 0, uvPerMetre = 1.6605974, centerX = 0.32559997, period = 1 },
            },
        },
        {
            mesh = "uel4511_lod0", vertexCount = 25017, bindPoseCount = 82,
            bands = {
                { ranges = { 20571, 6, 20637, 426 }, axis = 0, uvPerMetre = 0.17198826, centerX = -2.0204532, period = 1 },
                { ranges = { 21555, 6, 21621, 426 }, axis = 0, uvPerMetre = 0.17198826, centerX = -1.6700892, period = 1 },
                { ranges = { 21063, 6, 21129, 426 }, axis = 0, uvPerMetre = 0.17198826, centerX = 1.6700895, period = 1 },
                { ranges = { 20079, 6, 20145, 426 }, axis = 0, uvPerMetre = 0.17198826, centerX = 2.0220892, period = 1 },
            },
            textureQuality = {
                { property = "_MainTex", expectedName = "uel4511_uef_uel0401_albedo", anisoLevel = 16, filterMode = 2, mipMapBias = -0.35 },
                { property = "_NormalMap", expectedName = "uel4511_uef_uel0401_normal", anisoLevel = 16, filterMode = 2, mipMapBias = -0.35 },
                { property = "_MaskMap", expectedName = "uel4511_uef_uel0401_mask", anisoLevel = 16, filterMode = 2, mipMapBias = -0.35 },
            },
        },
        {
            mesh = "uel5003_lod0", vertexCount = 1758, bindPoseCount = 5,
            bands = {
                { ranges = { 579, 48 }, axis = 0, uvPerMetre = 3.8178468, centerX = -0.08397004, period = 1 },
                { ranges = { 531, 48 }, axis = 0, uvPerMetre = 3.8178458, centerX = -0.08397004, period = 1 },
                { ranges = { 306, 48 }, axis = 0, uvPerMetre = 3.8178453, centerX = -0.08397004, period = 1 },
                { ranges = { 627, 48 }, axis = 0, uvPerMetre = 3.8178468, centerX = 0.08397004, period = 1 },
                { ranges = { 675, 48 }, axis = 0, uvPerMetre = 3.8178458, centerX = 0.08397004, period = 1 },
                { ranges = { 222, 48 }, axis = 0, uvPerMetre = 3.8178453, centerX = 0.08397004, period = 1 },
            },
        },
        {
            mesh = "uel5004_lod0", vertexCount = 1758, bindPoseCount = 5,
            bands = {
                { ranges = { 531, 48 }, axis = 0, uvPerMetre = 2.1816266, centerX = -0.14694758, period = 1 },
                { ranges = { 579, 48 }, axis = 0, uvPerMetre = 2.1816268, centerX = -0.14694756, period = 1 },
                { ranges = { 306, 48 }, axis = 0, uvPerMetre = 2.1816263, centerX = -0.14694756, period = 1 },
                { ranges = { 627, 48 }, axis = 0, uvPerMetre = 2.1816268, centerX = 0.14694758, period = 1 },
                { ranges = { 675, 48 }, axis = 0, uvPerMetre = 2.1816266, centerX = 0.14694758, period = 1 },
                { ranges = { 222, 48 }, axis = 0, uvPerMetre = 2.1816263, centerX = 0.14694758, period = 1 },
            },
        },
        {
            mesh = "uel5006_lod0", vertexCount = 2694, bindPoseCount = 10,
            bands = {
                { ranges = { 522, 30, 558, 12 }, axis = 0, uvPerMetre = 0.766803, centerX = -0.18794733, period = 1 },
                { ranges = { 516, 6, 552, 6, 570, 12, 642, 18 }, axis = 0, uvPerMetre = 0.766803, centerX = 0.1879472, period = 1 },
            },
        },
        {
            mesh = "uel5008_lod0", vertexCount = 2670, bindPoseCount = 10,
            bands = {
                { ranges = { 1452, 60 }, axis = 0, uvPerMetre = 1.7957555, centerX = -0.2275, period = 1 },
                { ranges = { 738, 60 }, axis = 0, uvPerMetre = 1.7957546, centerX = -0.22749999, period = 1 },
                { ranges = { 510, 60 }, axis = 0, uvPerMetre = 1.7957546, centerX = -0.22749998, period = 1 },
                { ranges = { 678, 60 }, axis = 0, uvPerMetre = 1.7957555, centerX = 0.22749998, period = 1 },
                { ranges = { 618, 60 }, axis = 0, uvPerMetre = 1.7957541, centerX = 0.22749999, period = 1 },
                { ranges = { 1344, 60 }, axis = 0, uvPerMetre = 1.7957555, centerX = 0.2275, period = 1 },
            },
        },
        {
            mesh = "uel5009_lod0", vertexCount = 1902, bindPoseCount = 3,
            bands = {
                { ranges = { 1242, 48 }, axis = 0, uvPerMetre = 2.6239727, centerX = -0.14140975, period = 1 },
                { ranges = { 1338, 48 }, axis = 0, uvPerMetre = 2.6239724, centerX = -0.14140975, period = 1 },
                { ranges = { 1590, 48 }, axis = 0, uvPerMetre = 2.6239734, centerX = -0.14140975, period = 1 },
                { ranges = { 1854, 48 }, axis = 0, uvPerMetre = 2.6239727, centerX = 0.14140975, period = 1 },
                { ranges = { 231, 48 }, axis = 0, uvPerMetre = 2.6239724, centerX = 0.14140975, period = 1 },
                { ranges = { 345, 48 }, axis = 0, uvPerMetre = 2.6239734, centerX = 0.14140975, period = 1 },
            },
        },
        {
            mesh = "uel5010_lod0", vertexCount = 3342, bindPoseCount = 15,
            bands = {
                { ranges = { 1926, 66 }, axis = 0, uvPerMetre = 1.0785737, centerX = -0.243485, period = 1 },
                { ranges = { 1860, 66 }, axis = 0, uvPerMetre = 1.0785749, centerX = -0.24348491, period = 1 },
                { ranges = { 2298, 36, 2346, 30 }, axis = 0, uvPerMetre = -1.0785737, centerX = 0.24348491, period = 1 },
                { ranges = { 2208, 36, 2256, 30 }, axis = 0, uvPerMetre = -1.0785748, centerX = 0.24348491, period = 1 },
            },
        },
        {
            mesh = "uel5011_lod0", vertexCount = 4254, bindPoseCount = 14,
            bands = {
                { ranges = { 1779, 54 }, axis = 0, uvPerMetre = 0.2374314, centerX = -0.46903265, period = 1 },
                { ranges = { 969, 54 }, axis = 0, uvPerMetre = 0.20460205, centerX = -0.4558371, period = 1 },
                { ranges = { 1833, 54 }, axis = 0, uvPerMetre = 0.20460205, centerX = -0.4558371, period = 1 },
                { ranges = { 2130, 54 }, axis = 0, uvPerMetre = 0.20460205, centerX = 0.4558371, period = 1 },
                { ranges = { 2058, 54 }, axis = 0, uvPerMetre = 0.20460205, centerX = 0.4558371, period = 1 },
                { ranges = { 1725, 54 }, axis = 0, uvPerMetre = 0.2374314, centerX = 0.46903265, period = 1 },
            },
        },
        {
            mesh = "ugl1101_lod0", vertexCount = 2526, bindPoseCount = 8,
            bands = {
                { ranges = { 336, 30, 369, 30 }, axis = 0, uvPerMetre = 1.0863855, centerX = -0.17746267, period = 1 },
                { ranges = { 273, 60 }, axis = 0, uvPerMetre = 1.0863855, centerX = 0.17746267, period = 1 },
            },
        },
        {
            mesh = "ugl1501_lod0", vertexCount = 1800, bindPoseCount = 10,
            bands = {
                { ranges = { 1374, 72 }, axis = 0, uvPerMetre = 1.8295645, centerX = -0.20789997, period = 1 },
                { ranges = { 1302, 72 }, axis = 0, uvPerMetre = 1.8295647, centerX = -0.20789954, period = 1 },
                { ranges = { 1698, 72 }, axis = 0, uvPerMetre = 1.8295646, centerX = 0.20793231, period = 1 },
                { ranges = { 1626, 72 }, axis = 0, uvPerMetre = 1.8295647, centerX = 0.20793235, period = 1 },
            },
        },
        {
            mesh = "ugl2002_lod0", vertexCount = 1074, bindPoseCount = 13,
            bands = {
                { ranges = { 768, 24, 822, 18 }, axis = 0, uvPerMetre = 1.100689, centerX = -0.23660426, period = 1 },
                { ranges = { 840, 84 }, axis = 0, uvPerMetre = 1.2949283, centerX = 4.4703484E-08, period = 1 },
                { ranges = { 696, 24, 750, 18 }, axis = 0, uvPerMetre = 1.1006889, centerX = 0.23660429, period = 1 },
            },
        },
        {
            mesh = "ugl2201_lod0", vertexCount = 1770, bindPoseCount = 10,
            bands = {
                { ranges = { 594, 48 }, axis = 0, uvPerMetre = 1.4094125, centerX = -0.22542737, period = 1 },
                { ranges = { 642, 48 }, axis = 0, uvPerMetre = 1.4094125, centerX = -0.22542737, period = 1 },
                { ranges = { 690, 48 }, axis = 0, uvPerMetre = 1.4094123, centerX = -0.22542737, period = 1 },
                { ranges = { 834, 48 }, axis = 0, uvPerMetre = 1.4094125, centerX = 0.22542737, period = 1 },
                { ranges = { 786, 48 }, axis = 0, uvPerMetre = 1.4094125, centerX = 0.22542737, period = 1 },
                { ranges = { 738, 48 }, axis = 0, uvPerMetre = 1.4094123, centerX = 0.22542737, period = 1 },
            },
        },
        {
            mesh = "ugl2501_lod0", vertexCount = 2184, bindPoseCount = 11,
            bands = {
                { ranges = { 1758, 72 }, axis = 0, uvPerMetre = 1.3504721, centerX = -0.281619, period = 1 },
                { ranges = { 1686, 72 }, axis = 0, uvPerMetre = 1.3504729, centerX = -0.28161848, period = 1 },
                { ranges = { 2082, 72 }, axis = 0, uvPerMetre = 1.3504721, centerX = 0.28169802, period = 1 },
                { ranges = { 2010, 72 }, axis = 0, uvPerMetre = 1.3504729, centerX = 0.28169805, period = 1 },
            },
        },
        {
            mesh = "ugl3101_lod0", vertexCount = 2040, bindPoseCount = 11,
            bands = {
                { ranges = { 330, 54 }, axis = 0, uvPerMetre = 0.8170323, centerX = -0.5139153, period = 1 },
                { ranges = { 384, 54 }, axis = 0, uvPerMetre = 0.8170323, centerX = 0.5137858, period = 1 },
            },
        },
        {
            mesh = "ugl3501_lod0", vertexCount = 2736, bindPoseCount = 12,
            bands = {
                { ranges = { 2562, 72 }, axis = 0, uvPerMetre = 1.0513564, centerX = -0.36178395, period = 1 },
                { ranges = { 2634, 72 }, axis = 0, uvPerMetre = 1.0513563, centerX = -0.36178365, period = 1 },
                { ranges = { 2310, 72 }, axis = 0, uvPerMetre = 1.0513562, centerX = 0.3618428, period = 1 },
                { ranges = { 2238, 72 }, axis = 0, uvPerMetre = 1.0513562, centerX = 0.36184284, period = 1 },
            },
        },
        {
            mesh = "ugl4011_lod0", vertexCount = 4368, bindPoseCount = 35,
            bands = {
                { ranges = { 465, 72, 864, 6 }, axis = 0, uvPerMetre = 0.081899025, centerX = -2.2028823, period = 1 },
                { ranges = { 345, 72, 858, 6 }, axis = 0, uvPerMetre = 0.08192679, centerX = -2.2028823, period = 1 },
                { ranges = { 276, 69, 555, 3, 852, 6 }, axis = 0, uvPerMetre = 0.08192678, centerX = -2.2028823, period = 1 },
                { ranges = { 2067, 51, 2130, 6, 2151, 21 }, axis = 0, uvPerMetre = 0.08189903, centerX = 2.1106431, period = 1 },
                { ranges = { 1959, 72, 2124, 6 }, axis = 0, uvPerMetre = 0.08192679, centerX = 2.1106431, period = 1 },
                { ranges = { 1887, 72, 2118, 6 }, axis = 0, uvPerMetre = 0.08192678, centerX = 2.1106431, period = 1 },
            },
        },
        {
            mesh = "ugl5001_lod0", vertexCount = 957, bindPoseCount = 8,
            bands = {
                { ranges = { 540, 36, 720, 36 }, axis = 0, uvPerMetre = 3.1800346, centerX = -0.1454485, period = 1 },
                { ranges = { 756, 72 }, axis = 0, uvPerMetre = 3.1800346, centerX = -0.107948504, period = 1 },
                { ranges = { 648, 72 }, axis = 0, uvPerMetre = 3.1800344, centerX = -0.070448495, period = 1 },
                { ranges = { 504, 36, 576, 36 }, axis = 0, uvPerMetre = 3.1800344, centerX = 0.070448525, period = 1 },
                { ranges = { 468, 36, 612, 36 }, axis = 0, uvPerMetre = 3.180035, centerX = 0.107948534, period = 1 },
                { ranges = { 336, 72 }, axis = 0, uvPerMetre = 3.1800346, centerX = 0.14544852, period = 1 },
            },
        },
        {
            mesh = "ugl5002_lod0", vertexCount = 1410, bindPoseCount = 7,
            bands = {
                { ranges = { 561, 48 }, axis = 0, uvPerMetre = 0.5523675, centerX = -0.30902204, period = 1 },
                { ranges = { 213, 48 }, axis = 0, uvPerMetre = 0.5523675, centerX = 0.3089201, period = 1 },
            },
        },
        {
            mesh = "ugl5003_lod0", vertexCount = 864, bindPoseCount = 8,
            bands = {
                { ranges = { 342, 36 }, axis = 0, uvPerMetre = 0.59675753, centerX = -0.1579862, period = 1 },
                { ranges = { 294, 36 }, axis = 0, uvPerMetre = 0.59675753, centerX = 0.1579862, period = 1 },
            },
        },
        {
            mesh = "ugl5005_lod0", vertexCount = 2370, bindPoseCount = 12,
            bands = {
                { ranges = { 342, 36 }, axis = 0, uvPerMetre = 0.80562264, centerX = -0.11702682, period = 1 },
                { ranges = { 294, 36 }, axis = 0, uvPerMetre = 0.80562264, centerX = 0.11702682, period = 1 },
            },
        },
        {
            mesh = "usl1001_lod0", vertexCount = 2211, bindPoseCount = 8,
            bands = {
                { ranges = { 87, 18, 513, 12, 987, 24 }, axis = 0, uvPerMetre = 0.52933323, centerX = -0.1718719, period = 1 },
                { ranges = { 3, 30, 807, 12 }, axis = 0, uvPerMetre = 0.8850381, centerX = 0.22790255, period = 1 },
            },
        },
        {
            mesh = "usl2101_lod0", vertexCount = 2157, bindPoseCount = 4,
            bands = {
                { ranges = { 807, 18, 837, 18 }, axis = 0, uvPerMetre = 0.9642577, centerX = -0.39589494, period = 1 },
                { ranges = { 1323, 12, 1359, 24 }, axis = 0, uvPerMetre = 0.96425766, centerX = -0.105523266, period = 1 },
                { ranges = { 747, 18, 789, 18 }, axis = 0, uvPerMetre = 0.6698999, centerX = 0.3974204, period = 1 },
            },
        },
        {
            mesh = "usl3001_lod0", vertexCount = 2715, bindPoseCount = 16,
            bands = {
                { ranges = { 1515, 6, 1551, 30 }, axis = 0, uvPerMetre = 0.99812794, centerX = -0.48760608, period = 1 },
                { ranges = { 1383, 6, 1404, 30 }, axis = 0, uvPerMetre = 0.6902935, centerX = -2.9802322E-08, period = 1 },
                { ranges = { 1317, 6, 1338, 30 }, axis = 0, uvPerMetre = 0.68411905, centerX = 2.2351742E-08, period = 1 },
                { ranges = { 1449, 6, 1485, 30 }, axis = 0, uvPerMetre = 0.96482486, centerX = 0.48760608, period = 1 },
            },
        },
    },
}
