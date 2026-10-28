using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Reflection;

namespace SupremeCommanderOverhaulAeonStructureMotion;

internal static class NativeArrayByteFactory
{
	private sealed class Factory
	{
		private readonly ConstructorInfo constructor;

		private readonly object persistentAllocator;

		public Factory(ConstructorInfo constructor, object persistentAllocator)
		{
			this.constructor = constructor;
			this.persistentAllocator = persistentAllocator;
		}

		public object Create(byte[] bytes)
		{
			return constructor.Invoke(new object[2] { bytes, persistentAllocator });
		}
	}

	private static readonly ConcurrentDictionary<Type, Factory> Factories = new ConcurrentDictionary<Type, Factory>();

	public static object CreatePersistent(Type nativeArrayType, byte[] bytes)
	{
		if (nativeArrayType == null)
		{
			throw new ArgumentNullException("nativeArrayType");
		}
		if (bytes == null)
		{
			throw new ArgumentNullException("bytes");
		}
		return Factories.GetOrAdd(nativeArrayType, CreateFactory).Create(bytes);
	}

	private static Factory CreateFactory(Type nativeArrayType)
	{
		if (!nativeArrayType.IsGenericType || nativeArrayType.GetGenericArguments().Length != 1 || nativeArrayType.GetGenericArguments()[0] != typeof(byte))
		{
			throw new ArgumentException("Expected a closed Unity.Collections.NativeArray<byte>, got " + nativeArrayType.FullName + ".", "nativeArrayType");
		}
		Type type = nativeArrayType.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType("Unity.Collections.Allocator", throwOnError: false)).FirstOrDefault((Type type2) => type2 != null) ?? throw new TypeLoadException("The required runtime type was not loaded: Unity.Collections.Allocator");
		return new Factory(nativeArrayType.GetConstructor(BindingFlags.Instance | BindingFlags.Public, null, new Type[2]
		{
			typeof(byte[]),
			type
		}, null) ?? throw new MissingMethodException(nativeArrayType.FullName, ".ctor(Byte[], Allocator)"), Enum.Parse(type, "Persistent"));
	}
}
