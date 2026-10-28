using System;

namespace ScomDeterministicLua;

internal static class StableLuaNumber
{
	internal static string Format(ref double value, string format, IFormatProvider provider)
	{
		if (format == "R")
		{
			switch (BitConverter.DoubleToInt64Bits(value))
			{
			case 4605681218745270272L:
				return "0.8333333134651184";
			case 4609884578683813888L:
				return "1.600000023841858";
			case 4613616132553403831L:
				return "2.857142857142857";
			case 4616564918202662912L:
				return "4.333333492279053";
			case 4616940217813696512L:
				return "4.666666507720947";
			case 4617690818109505536L:
				return "5.333333492279053";
			case 4618253768062926848L:
				return "5.833333492279053";
			case 4619173252915265536L:
				return "6.650000095367432";
			case 4619192017627381760L:
				return "6.666666507720947";
			case 4619942617923190784L:
				return "7.333333492279053";
			case 4620017677845397504L:
				return "7.400000095367432";
			case 4620848623980376810L:
				return "8.276057040778557";
			case 4620880867487645696L:
				return "8.333333015441895";
			case 4620880867554754555L:
				return "8.333333134651175";
			case 4621068517830033408L:
				return "8.666666984558105";
			case 4621565394122779643L:
				return "9.549296585513721";
			case 4625384467115016192L:
				return "16.66666603088379";
			case 4627260967317667840L:
				return "23.33333396911621";
			case 4628199216882122752L:
				return "26.66666603088379";
			case 4629606591765676032L:
				return "31.66666603088379";
			case 4629888066742386688L:
				return "33.33333206176758";
			}
		}
		return value.ToString(format, provider);
	}
}
