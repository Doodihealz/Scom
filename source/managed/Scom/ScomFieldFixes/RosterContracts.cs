using ScomRepair20260913;

namespace ScomFieldFixes;

internal static class RosterContracts
{
	internal static readonly string[] ExistingIds = new string[309]
	{
		"uca1001", "uca1201", "uca1502", "uca1701", "uca2011", "uca2101", "uca2301", "uca2502", "uca2701", "uca2806",
		"uca3001", "uca3011", "uca3201", "uca3701", "uca4011", "ucl0000", "ucl1001", "ucl1002", "ucl1101", "ucl1201",
		"ucl1501", "ucl1701", "ucl2002", "ucl2101", "ucl2201", "ucl2501", "ucl2806", "ucl3001", "ucl3101", "ucl3501",
		"ucl3701", "ucl3801", "ucl4001", "ucl4002", "ucl4003", "ucl4004", "ucl4005", "ucl4401", "ucn1001", "ucn3001",
		"ucs1001", "ucs1201", "ucs1301", "ucs1501", "ucs1511", "ucs1512", "ucs1513", "ucs1601", "ucs1602", "ucs1611",
		"ucs1612", "ucs1614", "ucs1701", "ucs1702", "ucs1801", "ucs1802", "ucs1803", "ucs1804", "ucs2001", "ucs2101",
		"ucs2102", "ucs2201", "ucs2301", "ucs2401", "ucs2402", "ucs2501", "ucs2510", "ucs2511", "ucs2512", "ucs2513",
		"ucs2601", "ucs2611", "ucs2701", "ucs2702", "ucs2711", "ucs2801", "ucs2802", "ucs2803", "ucs2806", "ucs3001",
		"ucs3101", "ucs3102", "ucs3201", "ucs3401", "ucs3402", "ucs3501", "ucs3511", "ucs3512", "ucs3513", "ucs3601",
		"ucs3603", "ucs3611", "ucs3701", "ucs3702", "ucs4102", "uea0001", "uea1001", "uea1201", "uea1701", "uea2301",
		"uea3001", "uel0000", "uel1001", "uel1002", "uel1101", "uel1201", "uel1501", "uel1701", "uel2201", "uel2501",
		"uel3001", "uel3002", "uel3101", "uel3401", "uel3501", "uel4511", "uen1001", "uen1002", "uen2001", "uen2002",
		"uen3001", "uen3004", "uen3005", "uen4001", "ues1001", "ues1201", "ues1511", "ues1512", "ues1513", "ues1601",
		"ues1602", "ues1611", "ues1612", "ues1701", "ues2001", "ues2101", "ues2102", "ues2201", "ues2401", "ues2402",
		"ues2501", "ues2511", "ues2512", "ues2513", "ues2601", "ues2611", "ues2701", "ues3102", "ues3201", "ues3401",
		"ues3501", "ues3511", "ues3512", "ues3513", "ues3601", "ues3603", "ues3611", "ues3701", "ues4101", "uga1001",
		"uga1201", "uga1701", "uga2301", "uga3001", "ugl0000", "ugl1001", "ugl1002", "ugl1101", "ugl1501", "ugl1701",
		"ugl2002", "ugl2101", "ugl2201", "ugl2501", "ugl3001", "ugl3002", "ugl3101", "ugl3501", "ugl4001", "ugl4002",
		"ugl4011", "ugn1001", "ugn1002", "ugn2001", "ugn2002", "ugn3001", "ugn3003", "ugn3004", "ugn3005", "ugs1001",
		"ugs1201", "ugs1511", "ugs1512", "ugs1513", "ugs1601", "ugs1602", "ugs1611", "ugs1612", "ugs1701", "ugs2001",
		"ugs2101", "ugs2102", "ugs2201", "ugs2401", "ugs2402", "ugs2501", "ugs2511", "ugs2512", "ugs2513", "ugs2601",
		"ugs2611", "ugs2701", "ugs3101", "ugs3201", "ugs3401", "ugs3501", "ugs3511", "ugs3512", "ugs3513", "ugs3601",
		"ugs3603", "ugs3611", "ugs3701", "ugs4902", "ugs4903", "ugs4904", "ugs4905", "usa1001", "usa1201", "usa1502",
		"usa1701", "usa2011", "usa2101", "usa2301", "usa2502", "usa3001", "usa3201", "usa3701", "usa4011", "usl0000",
		"usl1001", "usl1101", "usl1201", "usl1501", "usl1701", "usl2002", "usl2101", "usl2201", "usl2501", "usl2806",
		"usl3001", "usl3101", "usl3501", "usl3801", "usl4002", "usl4004", "usl4401", "usn1001", "usn1002", "usn2001",
		"usn2002", "usn3001", "usn3003", "usn3004", "uss1001", "uss1201", "uss1301", "uss1511", "uss1512", "uss1513",
		"uss1601", "uss1602", "uss1611", "uss1612", "uss1614", "uss1701", "uss1702", "uss1804", "uss2001", "uss2101",
		"uss2102", "uss2201", "uss2301", "uss2401", "uss2402", "uss2510", "uss2511", "uss2512", "uss2513", "uss2601",
		"uss2611", "uss2701", "uss2702", "uss2711", "uss2806", "uss3101", "uss3102", "uss3201", "uss3401", "uss3402",
		"uss3501", "uss3511", "uss3512", "uss3513", "uss3601", "uss3603", "uss3611", "uss3701", "uss4102"
	};

	internal static readonly string[] NewIds = new string[229]
	{
		"uca5001", "ucl5001", "ucn5001", "ucs5001", "ucs5002", "ucs5003", "ucs5004", "ucs5005", "ucs5006", "ucs5007",
		"ucs5008", "uea5001", "uea5002", "uea5003", "uea5004", "uea5005", "uea5006", "uea5007", "uea5008", "uea5009",
		"uea5010", "uea5011", "uel5001", "uel5002", "uel5003", "uel5004", "uel5005", "uel5006", "uel5007", "uel5008",
		"uel5009", "uel5010", "uel5011", "uen5001", "uen5002", "uen5003", "ues5001", "ues5002", "ues5003", "ues5004",
		"ues5005", "ues5006", "ues5007", "ues5008", "ues5009", "ues5010", "ues5011", "ues5012", "ues5013", "ues5014",
		"ues5015", "ues5016", "ues5017", "ues5018", "ues5019", "ues5020", "ues5021", "ues5022", "ues5023", "ues5024",
		"ues5025", "ues5026", "ues5027", "ues5028", "ues5029", "ues5030", "ues5031", "ues5032", "ues5033", "ues5034",
		"ues5035", "ues5036", "ues5037", "ues5038", "ues5039", "ues5040", "ues5042", "ues5043", "ues5044", "ues5045",
		"ues5046", "ues5049", "ues5050", "ues5051", "ues5052", "ues5053", "ues5054", "ues5055", "ues5056", "ues5057",
		"ues5058", "ues5059", "ues5060", "ues5061", "ues5062", "ues5063", "ues5064", "ues5065", "ues5066", "ues5067",
		"ues5068", "ues5069", "ues5070", "ues5071", "ues5072", "ues5073", "ues5074", "ues5075", "ues5076", "ues5077",
		"ues5078", "ues5079", "ues5080", "ues5082", "ues5085", "ues5086", "ues5087", "ues5088", "ues5090", "ues5093",
		"ues5094", "uga5001", "uga5002", "uga5003", "uga5004", "uga5005", "uga5006", "uga5007", "uga5008", "uga5009",
		"ugl5001", "ugl5002", "ugl5003", "ugl5004", "ugl5005", "ugl5006", "ugn5001", "ugn5002", "ugs5001", "ugs5002",
		"ugs5003", "ugs5004", "ugs5005", "ugs5006", "ugs5007", "ugs5008", "ugs5009", "ugs5010", "ugs5011", "ugs5012",
		"ugs5013", "ugs5014", "ugs5015", "ugs5016", "ugs5017", "ugs5018", "ugs5019", "ugs5020", "ugs5021", "ugs5022",
		"ugs5023", "ugs5024", "ugs5025", "ugs5026", "ugs5027", "ugs5028", "ugs5029", "ugs5030", "ugs5031", "ugs5032",
		"ugs5033", "ugs5034", "ugs5035", "ugs5036", "ugs5037", "ugs5038", "ugs5039", "ugs5040", "ugs5041", "ugs5042",
		"ugs5043", "ugs5044", "ugs5045", "ugs5046", "ugs5047", "ugs5048", "ugs5049", "ugs5050", "ugs5051", "ugs5052",
		"ugs5053", "ugs5054", "ugs5055", "ugs5056", "ugs5057", "ugs5058", "ugs5059", "ugs5060", "ugs5061", "ugs5062",
		"ugs5063", "ugs5064", "ugs5065", "ugs5066", "ugs5067", "ugs5068", "usl5002", "uss5002", "uss5003", "uss5004",
		"uss5005", "uss5006", "uss5007", "uss5008", "uss5009", "uss5010", "uss5011", "uss5012", "uss5013", "uss5014",
		"uss5015", "uss5016", "uss5017", "uss5018", "uss5019", "uss5020", "uss5021", "uss5022", "uss5023"
	};

	internal static readonly string[] AllIds = new string[538]
	{
		"uca1001", "uca1201", "uca1502", "uca1701", "uca2011", "uca2101", "uca2301", "uca2502", "uca2701", "uca2806",
		"uca3001", "uca3011", "uca3201", "uca3701", "uca4011", "uca5001", "ucl0000", "ucl1001", "ucl1002", "ucl1101",
		"ucl1201", "ucl1501", "ucl1701", "ucl2002", "ucl2101", "ucl2201", "ucl2501", "ucl2806", "ucl3001", "ucl3101",
		"ucl3501", "ucl3701", "ucl3801", "ucl4001", "ucl4002", "ucl4003", "ucl4004", "ucl4005", "ucl4401", "ucl5001",
		"ucn1001", "ucn3001", "ucn5001", "ucs1001", "ucs1201", "ucs1301", "ucs1501", "ucs1511", "ucs1512", "ucs1513",
		"ucs1601", "ucs1602", "ucs1611", "ucs1612", "ucs1614", "ucs1701", "ucs1702", "ucs1801", "ucs1802", "ucs1803",
		"ucs1804", "ucs2001", "ucs2101", "ucs2102", "ucs2201", "ucs2301", "ucs2401", "ucs2402", "ucs2501", "ucs2510",
		"ucs2511", "ucs2512", "ucs2513", "ucs2601", "ucs2611", "ucs2701", "ucs2702", "ucs2711", "ucs2801", "ucs2802",
		"ucs2803", "ucs2806", "ucs3001", "ucs3101", "ucs3102", "ucs3201", "ucs3401", "ucs3402", "ucs3501", "ucs3511",
		"ucs3512", "ucs3513", "ucs3601", "ucs3603", "ucs3611", "ucs3701", "ucs3702", "ucs4102", "ucs5001", "ucs5002",
		"ucs5003", "ucs5004", "ucs5005", "ucs5006", "ucs5007", "ucs5008", "uea0001", "uea1001", "uea1201", "uea1701",
		"uea2301", "uea3001", "uea5001", "uea5002", "uea5003", "uea5004", "uea5005", "uea5006", "uea5007", "uea5008",
		"uea5009", "uea5010", "uea5011", "uel0000", "uel1001", "uel1002", "uel1101", "uel1201", "uel1501", "uel1701",
		"uel2201", "uel2501", "uel3001", "uel3002", "uel3101", "uel3401", "uel3501", "uel4511", "uel5001", "uel5002",
		"uel5003", "uel5004", "uel5005", "uel5006", "uel5007", "uel5008", "uel5009", "uel5010", "uel5011", "uen1001",
		"uen1002", "uen2001", "uen2002", "uen3001", "uen3004", "uen3005", "uen4001", "uen5001", "uen5002", "uen5003",
		"ues1001", "ues1201", "ues1511", "ues1512", "ues1513", "ues1601", "ues1602", "ues1611", "ues1612", "ues1701",
		"ues2001", "ues2101", "ues2102", "ues2201", "ues2401", "ues2402", "ues2501", "ues2511", "ues2512", "ues2513",
		"ues2601", "ues2611", "ues2701", "ues3102", "ues3201", "ues3401", "ues3501", "ues3511", "ues3512", "ues3513",
		"ues3601", "ues3603", "ues3611", "ues3701", "ues4101", "ues5001", "ues5002", "ues5003", "ues5004", "ues5005",
		"ues5006", "ues5007", "ues5008", "ues5009", "ues5010", "ues5011", "ues5012", "ues5013", "ues5014", "ues5015",
		"ues5016", "ues5017", "ues5018", "ues5019", "ues5020", "ues5021", "ues5022", "ues5023", "ues5024", "ues5025",
		"ues5026", "ues5027", "ues5028", "ues5029", "ues5030", "ues5031", "ues5032", "ues5033", "ues5034", "ues5035",
		"ues5036", "ues5037", "ues5038", "ues5039", "ues5040", "ues5042", "ues5043", "ues5044", "ues5045", "ues5046",
		"ues5049", "ues5050", "ues5051", "ues5052", "ues5053", "ues5054", "ues5055", "ues5056", "ues5057", "ues5058",
		"ues5059", "ues5060", "ues5061", "ues5062", "ues5063", "ues5064", "ues5065", "ues5066", "ues5067", "ues5068",
		"ues5069", "ues5070", "ues5071", "ues5072", "ues5073", "ues5074", "ues5075", "ues5076", "ues5077", "ues5078",
		"ues5079", "ues5080", "ues5082", "ues5085", "ues5086", "ues5087", "ues5088", "ues5090", "ues5093", "ues5094",
		"uga1001", "uga1201", "uga1701", "uga2301", "uga3001", "uga5001", "uga5002", "uga5003", "uga5004", "uga5005",
		"uga5006", "uga5007", "uga5008", "uga5009", "ugl0000", "ugl1001", "ugl1002", "ugl1101", "ugl1501", "ugl1701",
		"ugl2002", "ugl2101", "ugl2201", "ugl2501", "ugl3001", "ugl3002", "ugl3101", "ugl3501", "ugl4001", "ugl4002",
		"ugl4011", "ugl5001", "ugl5002", "ugl5003", "ugl5004", "ugl5005", "ugl5006", "ugn1001", "ugn1002", "ugn2001",
		"ugn2002", "ugn3001", "ugn3003", "ugn3004", "ugn3005", "ugn5001", "ugn5002", "ugs1001", "ugs1201", "ugs1511",
		"ugs1512", "ugs1513", "ugs1601", "ugs1602", "ugs1611", "ugs1612", "ugs1701", "ugs2001", "ugs2101", "ugs2102",
		"ugs2201", "ugs2401", "ugs2402", "ugs2501", "ugs2511", "ugs2512", "ugs2513", "ugs2601", "ugs2611", "ugs2701",
		"ugs3101", "ugs3201", "ugs3401", "ugs3501", "ugs3511", "ugs3512", "ugs3513", "ugs3601", "ugs3603", "ugs3611",
		"ugs3701", "ugs4902", "ugs4903", "ugs4904", "ugs4905", "ugs5001", "ugs5002", "ugs5003", "ugs5004", "ugs5005",
		"ugs5006", "ugs5007", "ugs5008", "ugs5009", "ugs5010", "ugs5011", "ugs5012", "ugs5013", "ugs5014", "ugs5015",
		"ugs5016", "ugs5017", "ugs5018", "ugs5019", "ugs5020", "ugs5021", "ugs5022", "ugs5023", "ugs5024", "ugs5025",
		"ugs5026", "ugs5027", "ugs5028", "ugs5029", "ugs5030", "ugs5031", "ugs5032", "ugs5033", "ugs5034", "ugs5035",
		"ugs5036", "ugs5037", "ugs5038", "ugs5039", "ugs5040", "ugs5041", "ugs5042", "ugs5043", "ugs5044", "ugs5045",
		"ugs5046", "ugs5047", "ugs5048", "ugs5049", "ugs5050", "ugs5051", "ugs5052", "ugs5053", "ugs5054", "ugs5055",
		"ugs5056", "ugs5057", "ugs5058", "ugs5059", "ugs5060", "ugs5061", "ugs5062", "ugs5063", "ugs5064", "ugs5065",
		"ugs5066", "ugs5067", "ugs5068", "usa1001", "usa1201", "usa1502", "usa1701", "usa2011", "usa2101", "usa2301",
		"usa2502", "usa3001", "usa3201", "usa3701", "usa4011", "usl0000", "usl1001", "usl1101", "usl1201", "usl1501",
		"usl1701", "usl2002", "usl2101", "usl2201", "usl2501", "usl2806", "usl3001", "usl3101", "usl3501", "usl3801",
		"usl4002", "usl4004", "usl4401", "usl5002", "usn1001", "usn1002", "usn2001", "usn2002", "usn3001", "usn3003",
		"usn3004", "uss1001", "uss1201", "uss1301", "uss1511", "uss1512", "uss1513", "uss1601", "uss1602", "uss1611",
		"uss1612", "uss1614", "uss1701", "uss1702", "uss1804", "uss2001", "uss2101", "uss2102", "uss2201", "uss2301",
		"uss2401", "uss2402", "uss2510", "uss2511", "uss2512", "uss2513", "uss2601", "uss2611", "uss2701", "uss2702",
		"uss2711", "uss2806", "uss3101", "uss3102", "uss3201", "uss3401", "uss3402", "uss3501", "uss3511", "uss3512",
		"uss3513", "uss3601", "uss3603", "uss3611", "uss3701", "uss4102", "uss5002", "uss5003", "uss5004", "uss5005",
		"uss5006", "uss5007", "uss5008", "uss5009", "uss5010", "uss5011", "uss5012", "uss5013", "uss5014", "uss5015",
		"uss5016", "uss5017", "uss5018", "uss5019", "uss5020", "uss5021", "uss5022", "uss5023"
	};

	internal static readonly string[] ProjectileIds = new string[205]
	{
		"pbf0001", "pbf0002", "pbf0003", "pbf0004", "pbf0005", "pbf0006", "pbf0007", "pbf0008", "pbf0009", "psf0001",
		"psf0002", "psf0003", "psf0004", "psf0005", "psf0006", "psf0007", "psf0008", "psf0009", "psf0010", "psf0011",
		"psf0012", "psf0013", "psf0014", "psf0015", "psf0016", "psf0017", "psf0018", "psf0019", "psf0020", "psf0021",
		"psf0022", "psf0023", "psf0024", "psf0025", "psf0026", "psf0027", "psf0028", "psf0029", "psf0030", "psf0031",
		"psf0032", "psf0033", "psf0034", "psf0035", "psf0036", "psf0037", "psf0038", "psf0039", "psf0040", "psf0041",
		"psf0042", "psf0043", "psf0044", "psf0045", "psf0046", "psf0047", "psf0048", "psf0049", "psf0050", "psf0051",
		"psf0052", "psf0053", "psf0054", "psf0055", "psf0056", "psf0057", "psf0058", "psf0059", "psf0060", "psf0061",
		"psf0062", "psf0063", "psf0064", "psf0065", "psf0066", "psf0067", "psf0068", "psf0069", "psf0070", "psf0071",
		"psf0072", "psf0073", "psf0074", "psf0075", "psf0076", "psf0077", "psf0078", "psf0079", "psf0080", "psf0081",
		"psf0082", "psf0083", "psf0084", "psf0085", "psf0086", "psf0087", "psf0088", "psf0089", "psf0090", "psf0091",
		"psf0092", "psf0093", "psf0094", "psf0095", "psf0096", "psf0097", "psf0098", "psf0099", "psf0100", "psf0101",
		"psf0102", "psf0103", "psf0104", "psf0105", "psf0106", "psf0107", "psf0108", "psf0109", "psf0110", "psf0111",
		"psf0112", "psf0113", "psf0114", "psf0115", "psf0116", "psf0117", "psf0118", "psf0119", "psf0120", "psf0121",
		"psf0122", "psf0123", "psf0124", "psf0125", "psf0126", "psf0127", "psf0128", "psf0129", "psf0130", "psf0131",
		"psf0132", "psf0133", "psf0134", "psf0135", "psf0136", "psf0137", "psf0138", "psf0139", "psf0140", "psf0141",
		"psf0142", "psf0143", "psf0144", "psf0145", "psf0146", "psf0147", "psf0148", "psf0149", "psf0150", "psf0151",
		"psf0152", "psf0153", "psf0154", "psf0155", "psf0156", "psf0157", "psf0158", "psf0159", "psf0160", "psf0161",
		"psf0162", "psf0163", "psf0164", "psf0165", "psf0166", "psf0167", "psf0168", "psf0169", "psf0170", "psf0171",
		"psf0172", "psf0173", "psf0174", "psf0175", "psf0176", "psf0177", "psf0178", "psf0179", "psf0180", "psf0181",
		"psf0182", "psf0183", "psf0184", "psf0185", "psf0186", "psf0187", "psf0188", "psf0189", "psf0190", "psf0191",
		"psf0192", "psf0193", "psf0194", "pxd003", "psf5035"
	};

	internal static string Tags(string id)
	{
		return Read("ScomFieldFixes.Roster.Tags." + id + ".lua");
	}

	internal static string Unit(string id)
	{
		return Read("ScomFieldFixes.Roster.Unit." + id + ".santp");
	}

	internal static string Read(string name)
	{
		string text = CacheCompatibilityRepair.ReadMockHydroResource(name);
		if (text != null)
		{
			return text;
		}
		return CacheCompatibilityRepair.ReadOriginalRosterResource(name);
	}
}
