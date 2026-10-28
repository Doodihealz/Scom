using System;
using System.Globalization;
using System.Text;
using ScomDeterministicLua;
using ScomRepair20260913;

namespace SupremeCommanderOverhaulUpgradeAnimationFix;

internal static class ProgressAnimationPolicy
{
	public const string MarkerPrefix = "-- Supreme Commander Overhaul Upgrade Animation Fix 1.0.0 ";

	public static string PatchTemplateSource(string source, ProgressAnimationSpec spec)
	{
		if (source == null)
		{
			throw new ArgumentNullException("source");
		}
		if (spec == null)
		{
			throw new ArgumentNullException("spec");
		}
		string token = "-- Supreme Commander Overhaul Upgrade Animation Fix 1.0.0 " + spec.UnitId;
		int num = Count(source, token);
		switch (num)
		{
		case 1:
			ValidateBinding(source, spec);
			RequireExactly(source, "SCOProgressAnimation.authoredSpeed = 1", 1, spec.UnitId + " managed progress freeze");
			return source;
		default:
			throw new InvalidOperationException($"{spec.UnitId} has {num} upgrade-animation markers.");
		case 0:
			ValidateBinding(source, spec);
			return source.TrimEnd(Array.Empty<char>()) + BuildAppendix(spec);
		}
	}

	private static void ValidateBinding(string source, ProgressAnimationSpec spec)
	{
		string text = CacheCompatibilityRepair.CanonicalLuaForProgress(source);
		int num = CacheCompatibilityRepair.LastCodeDeclarationIndex(text, "progressBoundUpgradeAnimation = {", spec.UnitId + " progress binding");
		int tableStart = text.IndexOf('{', num);
		int num2 = FindTableEnd(text, tableStart);
		string source2 = text.Substring(num, num2 - num + 1);
		RequireExactly(source2, "animationKey =", 1, spec.UnitId + " progress key declarations");
		RequireContains(source2, "animationKey = \"" + spec.BindingKey + "\"", spec.UnitId + " progress animation key");
		RequireExactly(source2, "restAnimationKey =", 1, spec.UnitId + " rest-key declarations");
		RequireContains(source2, "restAnimationKey = \"walk\"", spec.UnitId + " progress rest key");
		double num3 = ReadLuaNumber(source2, "durationSeconds =", spec.UnitId + " progress duration");
		if (!(Math.Abs(num3 - spec.SourceDurationSeconds) <= 1E-06))
		{
			throw new InvalidOperationException(spec.UnitId + " active progress duration does not match the pinned animation asset.");
		}
		num = CacheCompatibilityRepair.LastCodeDeclarationIndex(text, spec.BindingKey + " = {", spec.UnitId + " bound animation table");
		tableStart = text.IndexOf('{', num);
		num2 = FindTableEnd(text, tableStart);
		string text2 = text.Substring(num, num2 - num + 1);
		RequireExactly(text2, "clipName =", 1, spec.UnitId + " clip declarations");
		RequireContains(text2, "clipName = \"" + spec.SourceClip + "\"", spec.UnitId + " bound clip");
		RequireExactly(text2, "sanAnimationPath =", 1, spec.UnitId + " animation-path declarations");
		RequireContains(text2, "sanAnimationPath = \"" + spec.SourceAssetPath + "\"", spec.UnitId + " bound asset path");
		if (text2.IndexOf("playbackMode = 0", StringComparison.Ordinal) >= 0)
		{
			RequireExactly(text2, "playbackMode =", 1, spec.UnitId + " clamped-playback declarations");
		}
		else
		{
			RequireExactly(text, "UnitTemplate . visuals . animations . " + spec.BindingKey + " . playbackMode = 0", 1, spec.UnitId + " external clamped progress playback");
		}
		if (text2.IndexOf("authoredSpeed", StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException(spec.UnitId + " progress animation already has an unowned authored speed.");
		}
	}

	private static string BuildAppendix(ProgressAnimationSpec spec)
	{
		StringBuilder stringBuilder = new StringBuilder();
		stringBuilder.Append("\n\n").Append("-- Supreme Commander Overhaul Upgrade Animation Fix 1.0.0 ").AppendLine(spec.UnitId);
		stringBuilder.AppendLine("-- Static structures have zero simulation velocity. Marking only the");
		stringBuilder.AppendLine("-- progress-owned clip as velocity-scaled prevents native Burst playback");
		stringBuilder.AppendLine("-- from advancing after the managed exact-time delegate selects its pose.");
		stringBuilder.AppendLine("local SCOProgressBinding = UnitTemplate.additions and UnitTemplate.additions.progressBoundUpgradeAnimation");
		stringBuilder.AppendLine("local SCOProgressAnimations = UnitTemplate.visuals and UnitTemplate.visuals.animations");
		stringBuilder.Append("local SCOProgressAnimation = SCOProgressAnimations and ").Append("SCOProgressAnimations[\"").Append(spec.BindingKey)
			.AppendLine("\"]");
		stringBuilder.AppendLine("if not SCOProgressBinding");
		stringBuilder.Append("    or SCOProgressBinding.animationKey ~= \"").Append(spec.BindingKey).AppendLine("\"");
		stringBuilder.AppendLine("    or type(SCOProgressBinding.durationSeconds) ~= \"number\"");
		StringBuilder stringBuilder2 = stringBuilder.Append("    or math.abs(SCOProgressBinding.durationSeconds - ");
		double value = spec.SourceDurationSeconds;
		stringBuilder2.Append(StableLuaNumber.Format(ref value, "R", CultureInfo.InvariantCulture)).AppendLine(") > 0.000001");
		stringBuilder.AppendLine("    or not SCOProgressAnimation");
		stringBuilder.Append("    or SCOProgressAnimation.clipName ~= \"").Append(spec.SourceClip).AppendLine("\"");
		stringBuilder.Append("    or SCOProgressAnimation.sanAnimationPath ~= \"").Append(spec.SourceAssetPath).AppendLine("\"");
		stringBuilder.AppendLine("    or SCOProgressAnimation.playbackMode ~= 0");
		stringBuilder.AppendLine("then");
		stringBuilder.Append("    error(\"SCOM upgrade-animation contract drifted for ").Append(spec.UnitId).AppendLine(".\")");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine("if SCOProgressAnimation.authoredSpeed ~= nil and SCOProgressAnimation.authoredSpeed ~= 1 then");
		stringBuilder.Append("    error(\"SCOM upgrade-animation speed collided for ").Append(spec.UnitId).AppendLine(".\")");
		stringBuilder.AppendLine("end");
		stringBuilder.AppendLine("SCOProgressAnimation.authoredSpeed = 1");
		return stringBuilder.ToString().TrimEnd(Array.Empty<char>());
	}

	private static double ReadLuaNumber(string source, string token, string description)
	{
		int num = source.IndexOf(token, StringComparison.Ordinal);
		if (num < 0)
		{
			throw new InvalidOperationException(description + " is unavailable.");
		}
		for (num += token.Length; num < source.Length && char.IsWhiteSpace(source[num]); num++)
		{
		}
		int i;
		for (i = num; i < source.Length && (char.IsDigit(source[i]) || source[i] == '+' || source[i] == '-' || source[i] == '.' || source[i] == 'e' || source[i] == 'E'); i++)
		{
		}
		if (i == num || !double.TryParse(source.Substring(num, i - num), NumberStyles.Float, CultureInfo.InvariantCulture, out var result))
		{
			throw new InvalidOperationException(description + " is not numeric.");
		}
		return result;
	}

	private static int FindTableEnd(string source, int tableStart)
	{
		if (tableStart < 0 || source[tableStart] != '{')
		{
			throw new InvalidOperationException("Lua animation table has no opening brace.");
		}
		int num = 0;
		char c = '\0';
		bool flag = false;
		for (int i = tableStart; i < source.Length; i++)
		{
			char c2 = source[i];
			if (c != 0)
			{
				if (flag)
				{
					flag = false;
				}
				else if (c2 == '\\')
				{
					flag = true;
				}
				else if (c2 == c)
				{
					c = '\0';
				}
				continue;
			}
			switch (c2)
			{
			case '"':
			case '\'':
				c = c2;
				break;
			case '{':
				num++;
				break;
			case '}':
				num--;
				if (num == 0)
				{
					return i;
				}
				break;
			}
		}
		throw new InvalidOperationException("Lua animation table has no closing brace.");
	}

	private static int UniqueIndexOf(string source, string token, string description)
	{
		RequireExactly(source, token, 1, description);
		return source.IndexOf(token, StringComparison.Ordinal);
	}

	private static string Window(string source, int start, int maximumLength)
	{
		int length = Math.Min(maximumLength, source.Length - start);
		return source.Substring(start, length);
	}

	private static void RequireContains(string source, string token, string description)
	{
		if (source.IndexOf(token, StringComparison.Ordinal) < 0)
		{
			throw new InvalidOperationException(description + " is missing token: " + token);
		}
	}

	private static void RequireExactly(string source, string token, int expected, string description)
	{
		int num = Count(source, token);
		if (num != expected)
		{
			throw new InvalidOperationException($"Expected {expected} {description} token(s), found {num}.");
		}
	}

	private static int Count(string source, string token)
	{
		int num = 0;
		int startIndex = 0;
		while ((startIndex = source.IndexOf(token, startIndex, StringComparison.Ordinal)) >= 0)
		{
			num++;
			startIndex += token.Length;
		}
		return num;
	}
}
