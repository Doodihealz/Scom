using System;
using System.Collections;
using System.IO;
using System.Reflection;

namespace ScomShatterHost
{
    // This type lives in the preloader assembly. Resolve runtime types only once
    // the native main-thread startup hook runs and the chainloader owns a GameObject.
    public static class EmbeddedShatter
    {
        private const string Guid = "local.scom.yolona-shatter";
        private const string Resource = "SCOM.YolonaShatter.Runtime.dll";
        private const string PluginType = "ScomShatter.ShatterPlugin";
        private static Type runtime;
        private static bool started, starting;

        public static void Boot()
        {
            if (started || starting) return;
            starting = true;
            try
            {
                Type chainloader = FindType("BepInEx.Bootstrap.Chainloader");
                var plugins = (IDictionary)chainloader.GetProperty("PluginInfos").GetValue(null, null);
                object registered = plugins[Guid];
                if (registered != null && registered.GetType().GetProperty("Instance").GetValue(registered, null) != null)
                {
                    started = true;
                    return;
                }
                object manager = chainloader.GetProperty("ManagerObject").GetValue(null, null);
                if (manager == null) throw new InvalidOperationException("BepInEx manager is unavailable.");
                if (runtime == null)
                {
                    // The standalone loader can rename its assembly and attach the
                    // component to a different object without registering the GUID.
                    foreach (Assembly assembly in AppDomain.CurrentDomain.GetAssemblies())
                    {
                        Type old = assembly.GetType(PluginType, false);
                        if (old == null) continue;
                        Type unityObject = FindType("UnityEngine.Object");
                        var find = unityObject.GetMethod("FindObjectOfType", new[] { typeof(Type) });
                        if (find != null && find.Invoke(null, new object[] { old }) != null)
                        {
                            started = true;
                            return;
                        }
                    }
                    runtime = ReadPluginType();
                }

                Type gameObject = manager.GetType();
                var signature = new[] { typeof(Type) };
                object[] arguments = { runtime };
                object component = gameObject.GetMethod("GetComponent", signature).Invoke(manager, arguments)
                    ?? gameObject.GetMethod("AddComponent", signature).Invoke(manager, arguments);
                if (component == null) throw new InvalidOperationException("Shatter component creation failed.");
                object info = runtime.GetProperty("Info").GetValue(component, null);
                info.GetType().GetProperty("Location").SetValue(info, typeof(EmbeddedShatter).Assembly.Location, null);
                info.GetType().GetProperty("Instance").SetValue(info, component, null);
                plugins[Guid] = info;
                started = true;
            }
            catch (Exception error)
            {
                Console.WriteLine("[SCOM Shatter] Embedded startup failed: " + error.GetBaseException());
            }
            finally
            {
                starting = false;
            }
        }

        private static Type FindType(string name)
        {
            foreach (Assembly assembly in AppDomain.CurrentDomain.GetAssemblies())
            {
                Type type = assembly.GetType(name, false);
                if (type != null) return type;
            }
            throw new TypeLoadException(name);
        }

        private static Type ReadPluginType()
        {
            using (Stream stream = typeof(EmbeddedShatter).Assembly.GetManifestResourceStream(Resource))
            {
                if (stream == null) throw new FileNotFoundException(Resource);
                byte[] bytes = new byte[checked((int)stream.Length)];
                for (int offset = 0; offset < bytes.Length;)
                {
                    int n = stream.Read(bytes, offset, bytes.Length - offset);
                    if (n == 0) throw new EndOfStreamException(Resource);
                    offset += n;
                }
                return Assembly.Load(bytes).GetType(PluginType, true);
            }
        }
    }
}
