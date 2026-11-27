using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

// Source compatibility is optional. Publish a whole validated Lua module or keep its prior bytes.
internal static class OptionalAiSource
{
    private static readonly UTF8Encoding Utf8 = new UTF8Encoding(false, true);

    internal static void Apply(string path, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result,
        Func<string, string> transform)
    {
        if (TryPrepare(path, stock, result, transform, out var bytes)
            && (!stock.TryGetValue(path, out var original) || !ReferenceEquals(bytes, original)))
            result[path] = bytes;
    }

    internal static bool TryPrepare(string path, IDictionary<string, byte[]> stock, Dictionary<string, byte[]> result,
        Func<string, string> transform, out byte[] prepared)
    {
        prepared = null;
        if (!result.TryGetValue(path, out var source))
            stock.TryGetValue(path, out source);
        if (source == null)
        {
            Console.WriteLine("[SCOM AI] Skipped optional edit for " + path + " (module absent).");
            return false;
        }

        try
        {
            bool hasBom = source.Length >= 3 && source[0] == 0xef && source[1] == 0xbb && source[2] == 0xbf;
            int start = hasBom ? 3 : 0;
            string text = Utf8.GetString(source, start, source.Length - start);
            bool crlf = text.Contains("\r\n");
            string normalized = text.Replace("\r\n", "\n");
            if (normalized.IndexOf('\r') >= 0)
                throw new InvalidDataException("Unexpected carriage return.");
            string updated = transform(normalized);
            if (updated == normalized)
            {
                prepared = source;
                return true;
            }
            if (crlf)
                updated = updated.Replace("\n", "\r\n");
            prepared = Utf8.GetBytes(hasBom ? "\uFEFF" + updated : updated);
            return true;
        }
        catch (InvalidDataException error)
        {
            Console.WriteLine("[SCOM AI] Skipped optional edit for " + path + " (" + error.Message + ").");
        }
        catch (DecoderFallbackException)
        {
            Console.WriteLine("[SCOM AI] Skipped optional edit for " + path + " (unsupported text encoding).");
        }
        return false;
    }
}
