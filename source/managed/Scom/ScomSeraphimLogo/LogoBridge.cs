using System;
using System.IO;
using System.Reflection;

namespace ScomSeraphimLogo;

public static class LogoBridge
{
	private static Type runtime;

	private static Type GetRuntime()
	{
		if (runtime != null)
		{
			return runtime;
		}
		using (Stream stream = typeof(LogoBridge).Assembly.GetManifestResourceStream("ScomSeraphimLogo.Runtime.dll"))
		{
			if (stream == null)
			{
				throw new FileNotFoundException("The Seraphim logo runtime is missing.", "ScomSeraphimLogo.Runtime.dll");
			}
			byte[] array = new byte[checked((int)stream.Length)];
			int num;
			for (int i = 0; i < array.Length; i += num)
			{
				num = stream.Read(array, i, array.Length - i);
				if (num == 0)
				{
					throw new EndOfStreamException("The Seraphim logo runtime was truncated.");
				}
			}
			runtime = Assembly.Load(array).GetType("ScomSeraphimLogo.LogoRuntime", throwOnError: true);
		}
		return runtime;
	}

	public static object LoadSprite()
	{
		return GetRuntime().GetMethod("LoadSprite", BindingFlags.Static | BindingFlags.Public).Invoke(null, null);
	}

	public static void Configure(object dropdown)
	{
		GetRuntime().GetMethod("Configure", BindingFlags.Static | BindingFlags.Public).Invoke(null, new object[1] { dropdown });
	}
}
