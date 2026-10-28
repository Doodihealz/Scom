using System;
using System.Globalization;

namespace SupComStyleUI;

internal readonly struct ResourceProjection
{
	internal float Current { get; }

	internal float Capacity { get; }

	internal float NetPerSecond { get; }

	internal EconomyRunwayState State { get; }

	internal double Seconds { get; }

	internal ResourceProjection(float current, float capacity, float netPerSecond, EconomyRunwayState state, double seconds)
	{
		Current = current;
		Capacity = capacity;
		NetPerSecond = netPerSecond;
		State = state;
		Seconds = seconds;
	}

	internal string FormatRunway()
	{
		return State switch
		{
			EconomyRunwayState.Empty => "EMPTY", 
			EconomyRunwayState.Draining => "EMPTY " + FormatDuration(Seconds), 
			EconomyRunwayState.Stable => "STABLE", 
			EconomyRunwayState.Filling => "FULL " + FormatDuration(Seconds), 
			EconomyRunwayState.Full => "FULL", 
			_ => "--", 
		};
	}

	private static string FormatDuration(double seconds)
	{
		if (!IsFinite(seconds) || seconds < 0.0)
		{
			return "--";
		}
		if (seconds >= 359999.0)
		{
			return ">99H";
		}
		long num = (long)Math.Ceiling(seconds);
		long num2 = num / 3600;
		long num3 = num % 3600 / 60;
		long num4 = num % 60;
		if (num2 > 0)
		{
			return string.Format(CultureInfo.InvariantCulture, "{0}:{1:00}:{2:00}", num2, num3, num4);
		}
		return string.Format(CultureInfo.InvariantCulture, "{0}:{1:00}", num3, num4);
	}

	private static bool IsFinite(double value)
	{
		if (!double.IsNaN(value))
		{
			return !double.IsInfinity(value);
		}
		return false;
	}
}
