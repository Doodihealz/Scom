using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using EM.Controls.Cameras;
using EM.Map;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

namespace ScomShatter
{
    [DefaultExecutionOrder(1000)]
    public sealed class ShatterEffect : MonoBehaviour
    {
        internal const float Width=CampaignSurfaceAssets.NativeWidth, Length=CampaignSurfaceAssets.NativeLength;
        private const float Scale=CampaignSurfaceAssets.NativeScale;
        private const int AlbedoWidth=2048, AlbedoHeight=1024;
        private const string Assets="assets/campaign/";
        private static readonly List<ShatterEffect> sites=new List<ShatterEffect>();
        private static Material floorMaterial;
        private static Material[] frameMaterials;
        private static Mesh nativeFrame;
        private static bool reported;
        private ChasmWorld.Site strike;
        private bool presentationStarted;
        private static readonly Plane[] cameraPlanes=new Plane[6];
        private static Camera lastCamera;
        private static int planesFrame=-1;
        private static int updateFrame=-1;
        private static int surfaceUploadFrame=-1;

        private readonly List<Object> owned=new List<Object>();
        private readonly CancellationTokenSource cancellation=new CancellationTokenSource();
        private CampaignGround ground;
        private FractureLayout layout;
        private Transform geometry;
        private ShatterWater water;
        private SurfaceOpening opening;
        private CampaignFloor floor;
        private FractureProps props;
        private ImpactBurst burst;
        private ShatterAccents accents;
        private CampaignTimeline.Clock clock;
        private MeshRenderer surfaceRenderer, floorRenderer;
        private MeshFilter landFilter;
        private Mesh originalLand, mergedLand;
        private Rect planeMap;
        private bool overlapDirty=true, hasOverlap;
        private float overlapPhase;
        private GameObject interior;
        private Transform frameRoot, floorRoot;
        private Material land;
        private Texture2D cracks, displacement;
        private Task<Surface.BakedSurface> bake, preview;
        private Texture2D currentAlbedo, currentNormals;
        private bool fineDetail, fallbackTerrainDirty;
        private BakedWallProjection fallbackWalls;
        private TerrainAppearance captured;
        private Rect mapBounds;
        private float nextColorCheck;
        private bool hasAlbedo, usesMapSurface;
        private Vector3 center;
        private Rect footprint, patch;
        private RectInt heightmapArea;
        private float nextRefresh, previousPhase=-1;
        private int session, impactFrame;
        private bool ready, groundReady, dirty, open, loggedOpening;

        internal static bool Prepare()
        {
            Mesh surface=CampaignSurfaceAssets.Mesh;
            if(!surface.isReadable) throw new InvalidDataException("Campaign plane cannot be clipped at map edges.");
            nativeFrame=CampaignSurfaceAssets.Load<Mesh>(Assets+"interior-frame.mesh");
            if(!nativeFrame.isReadable || nativeFrame.subMeshCount!=4 || nativeFrame.vertexCount!=1349410)
                throw new InvalidDataException("Incomplete campaign interior geometry.");
            if(CampaignInterior.ReducedFrame.subMeshCount!=nativeFrame.subMeshCount)
                throw new InvalidDataException("Incomplete campaign frame distance mesh.");
            floorMaterial=SharedMaterial("interior-floor.mat");
            var layers=new Material[4];
            for(int i=0;i<layers.Length;i++) layers[i]=SharedMaterial("interior-layer-"+i+".mat");
            frameMaterials=layers;
            SharedMaterial("hole-edge-light.mat");
            SharedMaterial("smoke-cover.mat");
            if(CampaignSurfaceAssets.RayMesh.vertexCount!=8) throw new InvalidDataException("Missing campaign ray geometry.");
            ImpactBurst.Prepare();
            return true;
        }

        private static Material SharedMaterial(string key)
        {
            var material=CampaignSurfaceAssets.Load<Material>(Assets+key);
            if(material.shader==null || !material.shader.isSupported)
                throw new NotSupportedException("Unsupported campaign material "+key);
            return material;
        }

        internal static void Play(ChasmWorld.Site strike)
        {
            GameObject owner=null;
            try
            {
                float x=strike.Position.x, z=strike.Position.z;
                if(!Surface.TryGetBounds(out var map) || !map.Overlaps(strike.Bounds)
                    || !Surface.TryGetHeight(Mathf.Clamp(x,map.xMin,map.xMax),Mathf.Clamp(z,map.yMin,map.yMax),out float height)) return;
                owner=new GameObject("Yolona campaign shatter");
                var site=owner.AddComponent<ShatterEffect>();
                site.Initialize(new Vector3(x,height,z),map,strike);
                sites.Add(site);
            }
            catch(Exception ex)
            {
                if(owner!=null){ owner.SetActive(false);Destroy(owner); }
                Warn(ex);
            }
        }

        private T Own<T>(T asset) where T:Object { owned.Add(asset);return asset; }

        private void Initialize(Vector3 impact,Rect map,ChasmWorld.Site source)
        {
            center=impact;
            transform.position=impact;
            strike=source;
            clock=new CampaignTimeline.Clock(strike.ImpactTick);
            session=Surface.SessionId;
            layout=strike.Layout;
            geometry=new GameObject("Oriented campaign fracture").transform;
            geometry.SetParent(transform,false);
            geometry.localRotation=layout.Rotation;
            geometry.localScale=layout.Scale;
            impactFrame=Time.frameCount;
            mapBounds=map;
            var localFootprint=layout.SiteBounds(new Rect(-Width/2,-Length/2,Width,Length));
            footprint=new Rect(center.x+localFootprint.x,center.z+localFootprint.y,localFootprint.width,localFootprint.height);
            var mapLocal=layout.NativeBounds(new Rect(map.x-center.x,map.y-center.z,map.width,map.height));
            patch=Rect.MinMaxRect(Mathf.Max(-Width/2,mapLocal.xMin),Mathf.Max(-Length/2,mapLocal.yMin),
                Mathf.Min(Width/2,mapLocal.xMax),Mathf.Min(Length/2,mapLocal.yMax));
            if(patch.width<=0 || patch.height<=0) throw new InvalidDataException("Empty campaign footprint.");
            water=new ShatterWater(transform,patch,layout,layout.ToSite,p=>ground.Sample(p.x,p.y));
            ready=true;
        }

        private void PrepareGround()
        {
            Rect map=mapBounds;
            var mapLocal=layout.NativeBounds(new Rect(map.x-center.x,map.y-center.z,map.width,map.height));
            int resolution=MapManager.Terrain.terrainData.heightmapResolution-1;
            var worldPatch=layout.SiteBounds(patch);
            int x0=Mathf.FloorToInt((center.x+worldPatch.xMin-map.xMin)/map.width*resolution)-1;
            int z0=Mathf.FloorToInt((center.z+worldPatch.yMin-map.yMin)/map.height*resolution)-1;
            heightmapArea=new RectInt(x0,z0,Mathf.CeilToInt(worldPatch.width/map.width*resolution)+4,
                Mathf.CeilToInt(worldPatch.height/map.height*resolution)+4);

            land=Own(CampaignSurfaceAssets.CreateMaterial());
            cracks=land.GetTexture("_Cracks") as Texture2D;
            displacement=land.GetTexture("_Land_Displacement") as Texture2D;
            var plane=CampaignSurfaceAssets.Mesh;
            planeMap=new Rect(mapLocal.x/Scale,mapLocal.y/Scale,mapLocal.width/Scale,mapLocal.height/Scale);
            bool wholePlane=FrameSection.Contains(planeMap,plane.bounds);
            if(layout.IsFault)
                plane=wholePlane ? CampaignSurfaceAssets.WholeVariant(layout.FaultProfile)
                    : Own(FrameSection.WarpLand(plane,planeMap,layout.FaultProfile));
            else if(!wholePlane) plane=Own(FrameSection.Clip(plane,planeMap));
            surfaceRenderer=Render("Campaign Land Collapse",geometry,plane,new[]{land});
            landFilter=surfaceRenderer.GetComponent<MeshFilter>();
            originalLand=plane;
            surfaceRenderer.transform.localScale=Vector3.one*Scale;
            surfaceRenderer.allowOcclusionWhenDynamic=false;
            surfaceRenderer.enabled=false;
            CampaignTimeline.Apply(land,0);

            interior=new GameObject("Dyson sphere interior");
            interior.transform.SetParent(geometry,false);
            interior.SetActive(false);
            BuildInterior(mapLocal);
            opening=new SurfaceOpening(center,layout);
            ground=new CampaignGround(center,patch,layout);
            RefreshHeights();
            var mapped = MapSurfaceMaterial.TryCreate(land, ground, surfaceRenderer);
            if (mapped != null)
            {
                var previous = land;
                land = Own(mapped);
                usesMapSurface = true;
                owned.Remove(previous);
                Destroy(previous);
            }
            if(!usesMapSurface)
            {
                try { fallbackWalls=BakedWallProjection.Capture(layout); }
                catch(Exception ex) { Warn(new InvalidOperationException("Keeping the map surface fallback without wall projection.",ex)); }
            }
            props=new FractureProps(footprint,FallAge);
            groundReady=true;
        }

        private static MeshRenderer Render(string name,Transform parent,Mesh mesh,Material[] materials)
        {
            var owner=new GameObject(name);
            owner.transform.SetParent(parent,false);
            owner.AddComponent<MeshFilter>().sharedMesh=mesh;
            var renderer=owner.AddComponent<MeshRenderer>();
            renderer.sharedMaterials=materials;
            renderer.shadowCastingMode=ShadowCastingMode.On;
            renderer.receiveShadows=true;
            renderer.renderingLayerMask=257;
            renderer.lightProbeUsage=LightProbeUsage.BlendProbes;
            renderer.reflectionProbeUsage=ReflectionProbeUsage.BlendProbes;
            renderer.motionVectorGenerationMode=MotionVectorGenerationMode.Object;
            return renderer;
        }

        private void BuildInterior(Rect map)
        {
            var frame=new GameObject("Campaign Dyson frame");
            frameRoot=frame.transform;
            frameRoot.SetParent(interior.transform,false);
            Vector3 origin=CampaignInterior.FrameOffset;
            var frameMap=new Rect(map.x-origin.x,map.y-origin.z,map.width,map.height);
            var reduced=CampaignInterior.ReducedFrame;
            var detailed=nativeFrame;
            if(!FrameSection.Contains(frameMap,detailed.bounds)) detailed=Own(FrameSection.Clip(detailed,frameMap));
            if(!FrameSection.Contains(frameMap,reduced.bounds)) reduced=Own(FrameSection.Clip(reduced,frameMap));
            var near=Render("Beam01.035",frameRoot,detailed,frameMaterials);
            var far=Render("Beam01.035 distant",frameRoot,reduced,frameMaterials);
            var lod=frame.AddComponent<LODGroup>();
            lod.SetLODs(new[]{new LOD(.16f,new Renderer[]{near}),new LOD(0f,new Renderer[]{far})});
            lod.RecalculateBounds();
            floor=new CampaignFloor(center,map,layout);
            floorRenderer=Render("Dyson sphere interior floor",interior.transform,floor.Mesh,new[]{floorMaterial});
            floorRoot=floorRenderer.transform;
            floorRoot.localRotation=Quaternion.Euler(90,0,0);
            floorRoot.localScale=Vector3.one*CampaignInterior.FloorScale;
        }

        private void RefreshHeights()
        {
            ground.Update(land);
            surfaceRenderer.localBounds=ground.SurfaceBounds;
            frameRoot.localPosition=CampaignInterior.FrameOffset+Vector3.up*ground.InteriorOffset;
            floorRoot.localPosition=new Vector3(0,-CampaignInterior.FloorDepth+ground.InteriorOffset,CampaignInterior.RootZ);
            floor.RefreshRim(ground);
            water?.InvalidateHeights();
            dirty=false;
        }

        private float FallAge(float x,float z)
        {
            var source=layout.NativeToSource(layout.ToNative(new Vector2(x-center.x,z-center.z)));
            float lx=source.x, lz=source.y;
            float ex=lx/(SurfaceOpening.Width*.5f),ez=(lz-SurfaceOpening.OffsetZ)/(SurfaceOpening.Length*.5f);
            if(ex*ex+ez*ez>1 || cracks==null || displacement==null || !cracks.isReadable || !displacement.isReadable)
                return float.PositiveInfinity;
            float u=.5f-lx/Width,v=.5f+lz/Length;
            // The campaign graph takes the shallower of its static displacement
            // and animated profile. Remove a prop once its support drops 1.5 m.
            const float drop=1.5f;
            if((1f-displacement.GetPixelBilinear(u,v).b)*CampaignSurfaceAssets.MaximumLocalDrop*Scale<drop)
                return float.PositiveInfinity;
            // The native profile reaches 1 - 1.5/(4*scale) at texture V=.7725.
            // Undo the material's [-1.60,1.05] remap to find the crack threshold.
            const float threshold=(1.05f-.7725f)/2.65f;
            bool Falling(float phase) => phase-cracks.GetPixelBilinear(
                u+(u-.5f)*.2f*phase,v+(v-.5f)*.2f*phase).b >= threshold;
            float lo=0f;
            for(int sample=1;sample<=32;sample++)
            {
                float hi=CampaignTimeline.ShaderPhase(sample/32f);
                if(!Falling(hi)) { lo=hi;continue; }
                for(int i=0;i<4;i++)
                {
                    float mid=(hi+lo)*.5f;
                    if(Falling(mid)) hi=mid; else lo=mid;
                }
                return CampaignTimeline.AgeAtShaderPhase(hi);
            }
            return float.PositiveInfinity;
        }

        private bool FinishAlbedo()
        {
            if (bake!=null && bake.IsCompleted)
            {
                // A salvo may finish several workers together. Spread the large
                // texture uploads/compression across render frames.
                if(surfaceUploadFrame==Time.frameCount) return hasAlbedo;
                surfaceUploadFrame=Time.frameCount;
                UploadAlbedo(bake);
                bake=null;
                preview=null;
                nextColorCheck=Time.unscaledTime+2f;
                hasAlbedo=true;
            }
            else if (preview!=null && preview.IsCompleted)
            {
                UploadAlbedo(preview);
                preview=null;
                hasAlbedo=true;
            }
            return hasAlbedo;
        }

        private void UploadAlbedo(Task<Surface.BakedSurface> task)
        {
            var result=task.GetAwaiter().GetResult();
            // Maps without readable strata keep the campaign's own full-resolution surface.
            if(result==null) return;
            if(result.Albedo.Length!=result.Width*result.Height ||
                (result.Normals!=null && result.Normals.Length!=result.Albedo.Length))
                throw new InvalidDataException("Incomplete terrain surface.");
            var texture=UploadSurfaceTexture(result,result.Albedo,false);
            var normal=result.Normals==null?null:UploadSurfaceTexture(result,result.Normals,true);
            // Both uploads finish before replacing the displayed pair.
            land.SetTexture("_Diffuse",texture);
            if(currentAlbedo!=null) { owned.Remove(currentAlbedo);Destroy(currentAlbedo); }
            currentAlbedo=texture;
            if(normal!=null)
            {
                ground.SetSurfaceNormals(land,normal);
                // The atlas already contains map strata bumps. Retaining the
                // campaign's unrelated fractal detail would layer them twice.
                land.SetFloat("_Surface_Detail_Intensity",0f);
                if(currentNormals!=null) { owned.Remove(currentNormals);Destroy(currentNormals); }
                currentNormals=normal;
                fineDetail=result.Width>AlbedoWidth;
            }
        }

        private Texture2D UploadSurfaceTexture(Surface.BakedSurface result,Color32[] pixels,bool normal)
        {
            var texture=Own(new Texture2D(result.Width,result.Height,normal?TextureFormat.RGBA32:TextureFormat.RGB24,true,normal)
            { name=normal?"Campaign map strata normals":"Campaign local ground",
                wrapMode=TextureWrapMode.Clamp,filterMode=FilterMode.Trilinear,anisoLevel=8 });
            texture.SetPixels32(pixels);
            bool compress=SystemInfo.SupportsTextureFormat(normal?TextureFormat.DXT5:TextureFormat.DXT1);
            texture.Apply(true,!compress);
            if(compress) { texture.Compress(false);texture.Apply(false,true); }
            return texture;
        }

        private bool NeedsFineDetail(Camera camera) => camera!=null &&
            SystemInfo.SupportsTextureFormat(TextureFormat.DXT1) && SystemInfo.SupportsTextureFormat(TextureFormat.DXT5) &&
            surfaceRenderer.bounds.SqrDistance(camera.transform.position)<80f*80f;

        private void StartSurfaceBake(bool refreshTerrain, bool detailed)
        {
            int width=detailed?AlbedoWidth*2:AlbedoWidth, height=detailed?AlbedoHeight*2:AlbedoHeight;
            if(refreshTerrain || detailed && !fineDetail)
                captured=Surface.CaptureAlbedo(footprint,mapBounds,layout.Swapped?height:width,layout.Swapped?width:height);
            else captured=captured.WithCurrentCamera();
            fallbackTerrainDirty=false;
            bake=Surface.BakeAlbedoAsync(captured,mapBounds,center,layout,width,height,cancellation.Token,false,fallbackWalls);
        }

        private static void UpdateCameraPlanes(Camera camera)
        {
            if(lastCamera!=camera || planesFrame!=Time.frameCount)
            {
                GeometryUtility.CalculateFrustumPlanes(camera,cameraPlanes);
                lastCamera=camera;
                planesFrame=Time.frameCount;
            }
        }

        // The native range camera fits the view's intersection with a plane at
        // or above sea level. From below that plane it can shrink to 1 mm.
        // Include visible slabs in the terrain-hole projection in that case.
        internal static void CoverVisibleOpenings(float minYDir, ref Bounds ___renderBounds, ref float __result)
        {
            // The subsequent -.25 call fits the gameplay camera bounds.
            if (minYDir != -.05f || sites.Count == 0 || !RangesRenderer.holesActive) return;
            Camera view = MainCamera.Cam;
            if (view == null) return;
            UpdateCameraPlanes(view);
            Vector3 center = ___renderBounds.center;
            Vector2 half = Vector2.one * (.5f * __result);
            Vector2 low = new Vector2(center.x,center.z)-half, high = low+2f*half;
            Vector2 nativeLow = low, nativeHigh = high;
            foreach (var site in sites)
            {
                if (site == null || !site.isActiveAndEnabled || site.surfaceRenderer == null ||
                    !site.open || !GeometryUtility.TestPlanesAABB(cameraPlanes,site.surfaceRenderer.bounds)) continue;
                Bounds bank = site.surfaceRenderer.bounds;
                low = Vector2.Min(low,new Vector2(bank.min.x-1f,bank.min.z-1f));
                high = Vector2.Max(high,new Vector2(bank.max.x+1f,bank.max.z+1f));
            }
            if (low == nativeLow && high == nativeHigh) return;
            ___renderBounds.SetMinMax(new Vector3(low.x,___renderBounds.min.y,low.y),
                new Vector3(high.x,___renderBounds.max.y,high.y));
            __result = Mathf.Max(high.x-low.x,high.y-low.y);
        }

        private void UpdateVisibleSite(Camera camera)
        {
            UpdateCameraPlanes(camera);
            bool inView=GeometryUtility.TestPlanesAABB(cameraPlanes,surfaceRenderer.bounds);
            if(floorRenderer.enabled!=inView) floorRenderer.enabled=inView;
            if(!inView) return;
            floor.Update(camera,floorRoot.localPosition.y);
            if(usesMapSurface || bake!=null || captured==null || !captured.HasAlbedo || Time.unscaledTime<nextColorCheck) return;
            nextColorCheck=Time.unscaledTime+2f;
            bool detailed=fineDetail || NeedsFineDetail(camera);
            if(fallbackTerrainDirty || detailed!=fineDetail ||
                captured.NeedsDistanceRefresh(center,.5f*Mathf.Sqrt(footprint.width*footprint.width+footprint.height*footprint.height)))
            {
                StartSurfaceBake(fallbackTerrainDirty,detailed);
            }
        }

        private void LateUpdate()
        {
            if(updateFrame==Time.frameCount) return;
            updateFrame=Time.frameCount;
            MapSurfaceMaterial.Update();
            // Publish every site's phase before clipping any mesh. A salvo must
            // not rebuild against partially advanced neighbors and repeat next frame.
            for(int i=0;i<sites.Count;)
            {
                var site=sites[i];
                if(site==null) { sites.RemoveAt(i);continue; }
                site.UpdateSite();
                if(i<sites.Count && sites[i]==site) i++;
            }
            for(int i=0;i<sites.Count;)
            {
                var site=sites[i];
                try { site.UpdateOverlap(); }
                catch(Exception ex) { Warn(ex);site.Retire(); }
                if(i<sites.Count && sites[i]==site) i++;
            }
        }

        private void UpdateSite()
        {
            if(!ready) return;
            try
            {
                if(!Surface.IsReady || Surface.SessionId!=session){ Retire();return; }
                clock.Advance();
                float age=clock.ImpactAge;
                float blastAge=age*ImpactBurst.PlaybackRate;
                if(!presentationStarted && strike.PresentImpact && blastAge<ImpactBurst.ClipDuration)
                {
                    presentationStarted=true;
                    burst=new ImpactBurst(transform,Width*layout.ScaleX,Length*layout.ScaleZ,Mathf.Max(0f,strike.Position.y-center.y));
                    accents=ShatterAccents.Create(transform,center,layout);
                }
                if(burst!=null)
                {
                    if(blastAge>=ImpactBurst.ClipDuration) { burst.Dispose();burst=null; }
                    else burst.SetAge(blastAge);
                }
                if(accents!=null && accents.SetAge(blastAge,age))
                {
                    Destroy(accents.gameObject);
                    accents=null;
                }
                if(!groundReady)
                {
                    if(Time.frameCount==impactFrame || clock.ImpactAge<.12f) return;
                    PrepareGround();
                    return;
                }
                if(!usesMapSurface)
                {
                    if(captured==null)
                    {
                        bool detailed=NeedsFineDetail(MainCamera.Cam);
                        int width=detailed?AlbedoWidth*2:AlbedoWidth,height=detailed?AlbedoHeight*2:AlbedoHeight;
                        captured=Surface.CaptureAlbedo(footprint,mapBounds,layout.Swapped?height:width,layout.Swapped?width:height);
                        fallbackTerrainDirty=false;
                        bake=Surface.BakeAlbedoAsync(captured,mapBounds,center,layout,width,height,cancellation.Token,false,fallbackWalls);
                        preview=Surface.BakeAlbedoAsync(captured,mapBounds,center,layout,512,256,cancellation.Token,true,fallbackWalls);
                    }
                    if(!FinishAlbedo()) return;
                }
                if(dirty && Time.unscaledTime>=nextRefresh)
                {
                    RefreshHeights();
                    nextRefresh=Time.unscaledTime+.4f;
                }
                float phase=CampaignTimeline.Progress(age);
                if(phase!=previousPhase)
                {
                    CampaignTimeline.Apply(land,age);
                    previousPhase=phase;
                }
                bool visible=phase>0f && opening.Draw();
                SetOverlapPhase(phase,visible);
                water?.Update(phase,age,visible);
                if(visible) UpdateVisibleSite(MainCamera.Cam);
                if(open!=visible)
                {
                    surfaceRenderer.enabled=visible;
                    interior.SetActive(visible);
                    open=visible;
                    if(visible && !loggedOpening)
                    {
                        string shape = layout.IsFault ? "fault " + (layout.FaultProfile + 1) : "original";
                        Debug.Log("[SCOM Yolona shatter] Campaign Land Collapse active at " + center + " on " +
                            MapManager.mapFile.filePath + " (" + shape + ", " + (usesMapSurface ? "native map material" : "baked map material") +
                            FormattableString.Invariant($", yaw {layout.QuarterTurns * 90}, scale {layout.ScaleX:R} x {layout.ScaleZ:R})"));
                        loggedOpening=true;
                    }
                }
                props.SetAge(age,visible);
            }
            catch(Exception ex){ Warn(ex);Retire(); }
        }

        private void SetOverlapPhase(float phase, bool visible)
        {
            // Only intersecting shots rebuild their land meshes. Capture two
            // intermediate openings and always reconcile the finished geometry.
            float sample = !visible ? 0f : phase >= 1f ? 1f : phase >= .75f ? .75f : phase >= .5f ? .5f : 0f;
            if(sample != overlapPhase)
            {
                overlapPhase=sample;
                overlapDirty=true;
                NotifyOverlap();
            }
        }

        private void UpdateOverlap()
        {
            if(!open || !overlapDirty) return;
            overlapDirty=false;
            float sample=overlapPhase;
            List<SurfaceOverlap> neighbors=null;
            bool ownerFirst=false;
            foreach(var other in sites)
            {
                if(other==this) { ownerFirst=true; continue; }
                if(other==null || !other.ready || other.overlapPhase<=0f || !footprint.Overlaps(other.strike.Bounds)) continue;
                if(neighbors==null) neighbors=new List<SurfaceOverlap>();
                neighbors.Add(new SurfaceOverlap(new Vector2(other.center.x,other.center.z),other.strike.Bounds,
                    other.layout,other.overlapPhase,ownerFirst));
            }
            if(neighbors==null && !hasOverlap) return;
            Vector2 origin=new Vector2(center.x,center.z);
            float Keep(Vector3 vertex)
            {
                var native=new Vector2(vertex.x,vertex.z)*Scale;
                Vector2 world=origin+layout.ToSite(native);
                float ownDrop=-1f, keep=100f;
                foreach(var neighbor in neighbors)
                {
                    if(!neighbor.Applies(world)) continue;
                    if(ownDrop<0f) ownDrop=layout.Drop(native,sample);
                    keep=Mathf.Min(keep,neighbor.Keep(world,ownDrop));
                }
                return keep;
            }
            Func<Vector3,float> filter=neighbors==null ? null : (Func<Vector3,float>)Keep;
            Mesh next=null;
            if(filter!=null)
                next=layout.IsFault ? FrameSection.WarpLand(CampaignSurfaceAssets.Mesh,planeMap,layout.FaultProfile,filter)
                    : FrameSection.Clip(CampaignSurfaceAssets.Mesh,planeMap,filter);
            landFilter.sharedMesh=next==null ? originalLand : next;
            if(mergedLand!=null) Destroy(mergedLand);
            mergedLand=next;
            surfaceRenderer.localBounds=ground.SurfaceBounds;
            hasOverlap=filter!=null;
        }

        private void NotifyOverlap()
        {
            foreach(var other in sites)
                if(other!=null && other!=this && other.ready && other.footprint.Overlaps(strike.Bounds))
                    other.overlapDirty=true;
        }

        private void TerrainChanged(Terrain terrain,RectInt area,bool synced)
        {
            if(ready && terrain==MapManager.Terrain && heightmapArea.Overlaps(area))
            { dirty=true;fallbackTerrainDirty=true; }
        }

        private static void Warn(Exception ex)
        {
            if(reported) return;
            reported=true;
            Debug.LogWarning("[SCOM Yolona shatter] "+ex);
        }

        private void Retire()
        {
            if(overlapPhase>0f) { overlapPhase=0f; NotifyOverlap(); }
            sites.Remove(this);
            ready=false;
            cancellation.Cancel();
            props?.Dispose();
            gameObject.SetActive(false);
            Destroy(gameObject);
        }

        public static void Clear()
        {
            for(int i=sites.Count-1;i>=0;i--) if(sites[i]!=null) sites[i].Retire();
            sites.Clear();
            FractureProps.Clear();
            ImpactBurst.Reset();
            OpeningFootprint.Release();
            CampaignInterior.Release();
            CampaignSurfaceAssets.Release();
            MapSurfaceMaterial.Release();
            floorMaterial=null;frameMaterials=null;nativeFrame=null;
            lastCamera=null;planesFrame=-1;updateFrame=-1;surfaceUploadFrame=-1;
            Surface.Reset();
            reported=false;
        }

        private void OnEnable(){TerrainCallbacks.heightmapChanged+=TerrainChanged;}
        private void OnDisable(){TerrainCallbacks.heightmapChanged-=TerrainChanged;}
        private void OnDestroy()
        {
            cancellation.Cancel();cancellation.Dispose();
            if(overlapPhase>0f) NotifyOverlap();
            sites.Remove(this);
            if(usesMapSurface) MapSurfaceMaterial.Forget(land);
            if(mergedLand!=null) Destroy(mergedLand);
            water?.Dispose();burst?.Dispose();props?.Dispose();opening?.Dispose();floor?.Dispose();ground?.Dispose();
            foreach(var value in owned) if(value!=null) Destroy(value);
            owned.Clear();
        }
    }
}
