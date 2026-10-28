using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Reflection;

namespace SupremeCommanderOverhaul.Shared;

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
		if ((object)nativeArrayType == null)
		{
			throw new ArgumentNullException("nativeArrayType");
		}
		if (bytes == null)
		{
			throw new ArgumentNullException("bytes");
		}
		return Factories.GetOrAdd(nativeArrayType, CreateFactory).Create(bytes);
	}

	public static object CreatePersistent(Type nativeArrayType, byte[] first, byte[] second)
	{
		if (first == null)
		{
			throw new ArgumentNullException("first");
		}
		if (second == null)
		{
			throw new ArgumentNullException("second");
		}
		byte[] array = new byte[checked(first.Length + second.Length)];
		Buffer.BlockCopy(first, 0, array, 0, first.Length);
		Buffer.BlockCopy(second, 0, array, first.Length, second.Length);
		return CreatePersistent(nativeArrayType, array);
	}

	private static Factory CreateFactory(Type nativeArrayType)
	{
		if (!nativeArrayType.IsGenericType || nativeArrayType.GetGenericArguments().Length != 1 || nativeArrayType.GetGenericArguments()[0] != typeof(byte))
		{
			throw new ArgumentException("Expected a closed Unity.Collections.NativeArray<byte>, got " + nativeArrayType.FullName + ".", "nativeArrayType");
		}
		Type type = nativeArrayType.Assembly.GetType("Unity.Collections.Allocator", throwOnError: false) ?? (from assembly in AppDomain.CurrentDomain.GetAssemblies()
			select assembly.GetType("Unity.Collections.Allocator", throwOnError: false)).FirstOrDefault((Type type2) => (object)type2 != null) ?? throw new TypeLoadException("The required runtime type was not loaded: Unity.Collections.Allocator");
		ConstructorInfo constructor = nativeArrayType.GetConstructor(BindingFlags.Instance | BindingFlags.Public, null, new Type[2]
		{
			typeof(byte[]),
			type
		}, null) ?? throw new MissingMethodException(nativeArrayType.FullName, ".ctor(Byte[], Allocator)");
		object persistentAllocator = Enum.Parse(type, "Persistent");
		return new Factory(constructor, persistentAllocator);
	}
}
