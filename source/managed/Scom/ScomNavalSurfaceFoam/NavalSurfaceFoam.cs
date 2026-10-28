using System;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text;
using Mono.Cecil;
using Mono.Cecil.Cil;

namespace ScomNavalSurfaceFoam;

public static class NavalSurfaceFoam
{
	private const string MaterialPath = "VFX/SCOM/Naval/wake_foam.sanmaterial";

	private const string MaterialName = "SCOM Native Water Foam Mask";

	private const string ShaderName = "RTS/Particles/Unlit";

	private const int FoamLayer = 30;

	private static readonly bool[] reported = new bool[3];

	private static readonly bool[] errors = new bool[3];

	private static bool unidentifiedError;

	private static Assembly foamRuntime;

	private static object drawMaterial;

	public static void Install(AssemblyDefinition native)
	{
		if (native.MainModule.GetType().GetProperty("Mvid").GetValue(native.MainModule, null)
			.ToString() != "824eddf3-58d1-4a0a-824a-0153dcd374ee")
		{
			throw new InvalidOperationException("Naval surface foam Trebuchet MVID changed.");
		}
		TypeDefinition typeDefinition = null;
		foreach (TypeDefinition type in native.MainModule.Types)
		{
			if (type.FullName == "EM.Engine.Rendering.TxRenderSystem_EmitParticleSystem")
			{
				typeDefinition = type;
			}
		}
		MethodDefinition methodDefinition = null;
		if (typeDefinition != null)
		{
			foreach (MethodDefinition method in typeDefinition.Methods)
			{
				if (method.Name == "OnParticleSystemLoaded" && method.Parameters.Count == 1 && method.Parameters[0].ParameterType.FullName == "EM.Gamedata.Data/SanVfx")
				{
					if (methodDefinition != null)
					{
						throw new InvalidOperationException("Ambiguous native particle load method.");
					}
					methodDefinition = method;
				}
			}
		}
		if (methodDefinition == null || !methodDefinition.HasBody || methodDefinition.Body.Variables.Count != 15 || methodDefinition.Body.Variables[1].VariableType.FullName != "UnityEngine.GameObject")
		{
			throw new InvalidOperationException("Naval surface foam native load ABI changed.");
		}
		int num = 0;
		int num2 = 0;
		Instruction instruction = null;
		foreach (Instruction instruction2 in methodDefinition.Body.Instructions)
		{
			if (instruction2.Operand is MethodReference methodReference && methodReference.DeclaringType.FullName == "ScomNavalSurfaceFoam.NavalSurfaceFoam" && methodReference.Name == "Configure")
			{
				num++;
			}
			if (instruction2.OpCode == OpCodes.Ret)
			{
				num2++;
				instruction = instruction2;
			}
		}
		switch (num)
		{
		case 1:
			break;
		case 0:
			if (num2 == 1 && instruction != null && !(instruction.Previous.OpCode != OpCodes.Newobj) && !(((MethodReference)instruction.Previous.Operand).DeclaringType.FullName != "EM.Core.PrefabID"))
			{
				foreach (Instruction instruction3 in methodDefinition.Body.Instructions)
				{
					if (instruction3.Operand == instruction)
					{
						throw new InvalidOperationException("Native particle load branches directly to its return.");
					}
				}
				using AssemblyDefinition assemblyDefinition = AssemblyDefinition.ReadAssembly(Assembly.GetExecutingAssembly().Location);
				MethodDefinition methodDefinition2 = null;
				foreach (TypeDefinition type2 in assemblyDefinition.MainModule.Types)
				{
					if (!(type2.FullName == "ScomNavalSurfaceFoam.NavalSurfaceFoam"))
					{
						continue;
					}
					foreach (MethodDefinition method2 in type2.Methods)
					{
						if (method2.Name == "Configure")
						{
							methodDefinition2 = method2;
						}
					}
				}
				if (methodDefinition2 == null)
				{
					throw new MissingMethodException("Naval surface foam Configure is unavailable.");
				}
				ILProcessor iLProcessor = methodDefinition.Body.GetILProcessor();
				iLProcessor.InsertBefore(instruction, iLProcessor.Create(OpCodes.Ldarg_1));
				iLProcessor.InsertBefore(instruction, iLProcessor.Create(OpCodes.Ldloc_1));
				iLProcessor.InsertBefore(instruction, iLProcessor.Create(OpCodes.Call, native.MainModule.ImportReference(methodDefinition2)));
				methodDefinition.Body.MaxStackSize = Math.Max(methodDefinition.Body.MaxStackSize, 3);
				break;
			}
			goto default;
		default:
			throw new InvalidOperationException("Naval surface foam native load anchor changed.");
		}
	}

	public static void Configure(object source, object prefab)
	{
		int num = -1;
		string text = "<unidentified>";
		object obj = null;
		bool flag = false;
		bool flag2 = false;
		try
		{
			if (source == null || prefab == null)
			{
				return;
			}
			text = (string)Read(source, "LoadedPath");
			num = PathIndex(text);
			if (num >= 0)
			{
				Array array = (Array)Read(source, "particleSystems");
				if (array == null || array.Length != 2 || Convert.ToInt32(Read(array.GetValue(1), "ownerId"), CultureInfo.InvariantCulture) != 1 || (string)Read(Read(array.GetValue(1), "rendering"), "material") != "VFX/SCOM/Naval/wake_foam.sanmaterial")
				{
					throw new InvalidOperationException("Wake source does not contain the reviewed foam material.");
				}
				Type type = source.GetType().Assembly.GetType("EM.Gamedata.ParticleSystemAdditionalData", throwOnError: true);
				object value = Component(prefab, type);
				Array array2 = (Array)Read(value, "subparticles");
				if (array2 == null || array2.Length != 1)
				{
					throw new InvalidOperationException("Wake must contain exactly one native foam child.");
				}
				object obj2 = Read(array2.GetValue(0), "particleSystem");
				Type type2 = Type.GetType("UnityEngine.ParticleSystem, UnityEngine.ParticleSystemModule", throwOnError: true);
				Type type3 = type2.Assembly.GetType("UnityEngine.ParticleSystemRenderer", throwOnError: true);
				obj = Component(obj2, type3);
				object obj3 = Read(obj, "sharedMaterial");
				string text2 = (string)Read(obj3, "name");
				string text3 = (string)Read(Read(obj3, "shader"), "name");
				if (text2 != "SCOM Native Water Foam Mask" || text3 != "RTS/Particles/Unlit")
				{
					throw new InvalidOperationException("Unexpected wake material/shader: " + text2 + " / " + text3);
				}
				flag = true;
				object obj4 = Read(obj, "gameObject");
				PropertyInfo property = obj4.GetType().GetProperty("layer");
				if (property == null || !property.CanWrite)
				{
					throw new MissingMemberException("Wake GameObject.layer");
				}
				PropertyInfo property2 = obj.GetType().GetProperty("enableGPUInstancing");
				object obj5 = Read(obj2, "main");
				PropertyInfo property3 = obj5.GetType().GetProperty("cullingMode");
				if (property2 == null || !property2.CanWrite || property3 == null || !property3.CanWrite)
				{
					throw new MissingMemberException("Wake native renderer/simulation controls");
				}
				ConfigureWhiteMaterial(obj3);
				EnsurePass(GetDrawMaterial(obj3));
				property2.SetValue(obj, false, null);
				property3.SetValue(obj5, Enum.Parse(property3.PropertyType, "AlwaysSimulate"), null);
				property.SetValue(obj4, 30, null);
				if (Convert.ToInt32(property.GetValue(obj4, null), CultureInfo.InvariantCulture) != 30)
				{
					throw new InvalidOperationException("Wake dedicated layer assignment did not persist.");
				}
				if ((bool)property2.GetValue(obj, null) || property3.GetValue(obj5, null).ToString() != "AlwaysSimulate")
				{
					throw new InvalidOperationException("Wake native rendering/simulation settings did not persist.");
				}
				flag2 = true;
				if (!reported[num])
				{
					string text4 = Snapshot(text, obj2, obj, obj3);
					reported[num] = true;
					Log(error: false, "[SCOM naval surface foam] " + text4 + " layer=" + 30);
				}
			}
		}
		catch (Exception ex)
		{
			if (flag && !flag2)
			{
				try
				{
					obj.GetType().GetProperty("enabled").SetValue(obj, false, null);
				}
				catch (Exception ex2)
				{
					ex = new InvalidOperationException(ex.Message + "; could not disable mask: " + ex2.Message, ex);
				}
			}
			if (!((num >= 0) ? errors[num] : unidentifiedError))
			{
				if (num >= 0)
				{
					errors[num] = true;
				}
				else
				{
					unidentifiedError = true;
				}
				Exception ex3 = ((ex is TargetInvocationException && ex.InnerException != null) ? ex.InnerException : ex);
				Log(error: true, "[SCOM naval surface foam] failed " + text + ": " + ex3.GetType().Name + ": " + ex3.Message);
			}
		}
	}

	private static object GetDrawMaterial(object source)
	{
		if (drawMaterial == null)
		{
			drawMaterial = Activator.CreateInstance(source.GetType(), source);
			Set(drawMaterial, "name", "SCOM White Foam Draw");
		}
		ConfigureWhiteMaterial(drawMaterial);
		return drawMaterial;
	}

	private static void EnsurePass(object material)
	{
		if (foamRuntime == null)
		{
			Assembly executingAssembly = Assembly.GetExecutingAssembly();
			using Stream stream = executingAssembly.GetManifestResourceStream("ScomNavalSurfaceFoam.WhiteFoamRuntime.dll");
			if (stream == null)
			{
				throw new InvalidOperationException("White foam runtime resource missing.");
			}
			using MemoryStream memoryStream = new MemoryStream();
			stream.CopyTo(memoryStream);
			foamRuntime = Assembly.Load(memoryStream.ToArray());
		}
		Type type = foamRuntime.GetType("ScomNavalSurfaceFoamRuntime.FoamPasses", throwOnError: true);
		MethodInfo method = type.GetMethod("Install", BindingFlags.Static | BindingFlags.Public);
		if (method == null)
		{
			throw new MissingMethodException(type.FullName, "Install");
		}
		method.Invoke(null, new object[1] { material });
	}

	private static void ConfigureWhiteMaterial(object material)
	{
		Type type = material.GetType();
		Type type2 = type.Assembly.GetType("UnityEngine.Color", throwOnError: true);
		type.GetMethod("SetColor", new Type[2]
		{
			typeof(string),
			type2
		}).Invoke(material, new object[2]
		{
			"_Emission",
			Activator.CreateInstance(type2, 5.992157f, 5.992157f, 5.992157f, 1f)
		});
		type.GetMethod("SetColor", new Type[2]
		{
			typeof(string),
			type2
		}).Invoke(material, new object[2]
		{
			"_EmissionColor",
			Activator.CreateInstance(type2, 1f, 1f, 1f, 1f)
		});
		MethodInfo method = type.GetMethod("SetFloat", new Type[2]
		{
			typeof(string),
			typeof(float)
		});
		string[] array = new string[16]
		{
			"_SurfaceType", "_BlendMode", "_SrcBlend", "_DstBlend", "_DstBlend2", "_AlphaSrcBlend", "_AlphaDstBlend", "_ZWrite", "_TransparentZWrite", "_CullMode",
			"_CullModeForward", "_TransparentCullMode", "_ZTestTransparent", "_ZTestDepthEqualForOpaque", "_EnableFogOnTransparent", "_BILLBOARD"
		};
		object[] array2 = new object[16]
		{
			1f, 1f, 1f, 1f, 10f, 1f, 10f, 0f, 0f, 0f,
			0f, 0f, 4f, 4f, 0f, 0f
		};
		for (int i = 0; i < array.Length; i++)
		{
			method.Invoke(material, new object[2]
			{
				array[i],
				array2[i]
			});
		}
		type.GetMethod("EnableKeyword", new Type[1] { typeof(string) }).Invoke(material, new object[1] { "_SURFACE_TYPE_TRANSPARENT" });
		type.GetMethod("EnableKeyword", new Type[1] { typeof(string) }).Invoke(material, new object[1] { "_BILLBOARD_NONE" });
		string[] array3 = new string[4] { "_ENABLE_FOG_ON_TRANSPARENT", "_ALPHATEST_ON", "_BILLBOARD_BILLBOARD", "_BILLBOARD_STRETCHEDBILLBOARD" };
		foreach (string text in array3)
		{
			type.GetMethod("DisableKeyword", new Type[1] { typeof(string) }).Invoke(material, new object[1] { text });
		}
	}

	private static void Set(object target, string name, object value)
	{
		Type type = target.GetType();
		PropertyInfo property = type.GetProperty(name, BindingFlags.Instance | BindingFlags.Public);
		if (property != null)
		{
			property.SetValue(target, value, null);
			return;
		}
		FieldInfo field = type.GetField(name, BindingFlags.Instance | BindingFlags.Public);
		if (field != null)
		{
			field.SetValue(target, value);
			return;
		}
		throw new MissingMemberException(type.FullName, name);
	}

	private static void SetEnum(object target, string name, string value)
	{
		Type type = Read(target, name).GetType();
		Set(target, name, Enum.Parse(type, value));
	}

	private static int PathIndex(string path)
	{
		return path switch
		{
			"VFX/SCOM/Naval/boat_wake.sanvfx" => 0, 
			"VFX/SCOM/Naval/boat_wake_medium.sanvfx" => 1, 
			"VFX/SCOM/Naval/boat_wake_large.sanvfx" => 2, 
			_ => -1, 
		};
	}

	private static object Component(object target, Type type)
	{
		if (target == null)
		{
			throw new InvalidOperationException("Wake component owner missing: " + type.FullName);
		}
		MethodInfo method = target.GetType().GetMethod("GetComponent", new Type[1] { typeof(Type) });
		if (method == null)
		{
			throw new MissingMethodException(target.GetType().FullName, "GetComponent(Type)");
		}
		object obj = method.Invoke(target, new object[1] { type });
		if (obj == null)
		{
			throw new InvalidOperationException("Wake component missing: " + type.FullName);
		}
		return obj;
	}

	private static object Read(object value, string name)
	{
		if (value == null)
		{
			throw new InvalidOperationException("Missing wake value for " + name);
		}
		Type type = value.GetType();
		PropertyInfo property = type.GetProperty(name, BindingFlags.Instance | BindingFlags.Public);
		if (property != null)
		{
			return property.GetValue(value, null);
		}
		FieldInfo field = type.GetField(name, BindingFlags.Instance | BindingFlags.Public);
		if (field != null)
		{
			return field.GetValue(value);
		}
		throw new MissingMemberException(type.FullName, name);
	}

	private static object MaterialValue(object material, string method, string property)
	{
		MethodInfo method2 = material.GetType().GetMethod(method, new Type[1] { typeof(string) });
		if (method2 == null)
		{
			throw new MissingMethodException(material.GetType().FullName, method);
		}
		return method2.Invoke(material, new object[1] { property });
	}

	private static string Snapshot(string path, object foam, object renderer, object material)
	{
		StringBuilder stringBuilder = new StringBuilder(path);
		stringBuilder.Append(" shader=").Append(Read(Read(material, "shader"), "name"));
		stringBuilder.Append(" material=").Append(Read(material, "name"));
		stringBuilder.Append(" queue=").Append(Read(material, "renderQueue"));
		stringBuilder.Append(" keywords=[").Append(string.Join(",", (string[])Read(material, "shaderKeywords"))).Append(']');
		object obj = MaterialValue(material, "GetTexture", "_MainTex");
		stringBuilder.Append(" texture=").Append((obj == null) ? "<missing>" : Read(obj, "name"));
		stringBuilder.Append(" _Emission=").Append(MaterialValue(material, "GetColor", "_Emission"));
		stringBuilder.Append(" _EmissionColor=").Append(MaterialValue(material, "GetColor", "_EmissionColor"));
		stringBuilder.Append(" _MainTex_ST=").Append(MaterialValue(material, "GetVector", "_MainTex_ST"));
		string[] array = new string[6] { "_SurfaceType", "_BlendMode", "_SrcBlend", "_DstBlend", "_ZWrite", "_EnableFogOnTransparent" };
		foreach (string text in array)
		{
			stringBuilder.Append(' ').Append(text).Append('=')
				.Append(MaterialValue(material, "GetFloat", text));
		}
		stringBuilder.Append(" startColor=").Append(Read(Read(Read(foam, "main"), "startColor"), "color"));
		stringBuilder.Append(" cullingMode=").Append(Read(Read(foam, "main"), "cullingMode"));
		stringBuilder.Append(" renderingLayerMask=").Append(Read(renderer, "renderingLayerMask"));
		stringBuilder.Append(" gpuInstancing=").Append(Read(renderer, "enableGPUInstancing"));
		return stringBuilder.ToString();
	}

	private static void Log(bool error, string message)
	{
		try
		{
			Type type = Type.GetType("UnityEngine.Debug, UnityEngine.CoreModule", throwOnError: true);
			type.GetMethod(error ? "LogError" : "LogWarning", new Type[1] { typeof(object) }).Invoke(null, new object[1] { message });
		}
		catch (Exception)
		{
			Console.Error.WriteLine(message);
		}
	}
}
