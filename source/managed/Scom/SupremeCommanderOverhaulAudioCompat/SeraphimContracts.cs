namespace SupremeCommanderOverhaulAudioCompat;

internal static class SeraphimContracts
{
	public static readonly LandFactoryContract[] LandFactories = new LandFactoryContract[3]
	{
		new LandFactoryContract("uss1511", -0.1, ("Pod01", 5.0)),
		new LandFactoryContract("uss2511", -0.35, ("Pod01", 5.0), ("Pod02", 8.0)),
		new LandFactoryContract("uss3511", -0.35, ("Pod01", 5.0), ("Pod02", 8.0), ("Pod03", -3.0))
	};

	public static readonly DeathContract[] DeathAnimations = new DeathContract[49]
	{
		new DeathContract("usl1201", "SeraphimLandUnit", C("source_animadeath", 100, 1.7333333492279053, 0.5, 1.5), C("source_animadeath02", 100, 2.1666667461395264, 0.5, 1.5), C("source_animadeath03", 100, 2.1666667461395264, 0.5, 1.5)),
		new DeathContract("usl1701", "SeraphimLandUnit", C("source_animadeath01", 100, 1.1666666269302368, null, null), C("source_animadeath02", 100, 1.1666666269302368, null, null), C("source_animadeath03", 100, 1.1666666269302368, null, null)),
		new DeathContract("usl2002", "SeraphimLandUnit", C("source_animadeath", 100, 2.0, 0.5, 1.5), C("source_animadeath02", 100, 2.0, 0.5, 1.5), C("source_animadeath03", 100, 1.600000023841858, 0.5, 1.5)),
		new DeathContract("usl2201", "SeraphimLandUnit", C("source_animadeath", 1, 1.1666666269302368, 1.0, 1.0)),
		new DeathContract("usl2806", "SeraphimLandUnit", C("source_animadeath", 100, 1.0, 0.5, 1.5)),
		new DeathContract("usl3101", "SeraphimLandUnit", C("source_animadeath01", 100, 2.0, 0.5, 1.5), C("source_animadeath02", 100, 2.0, 0.5, 1.5), C("source_animadeath03", 100, 2.6666667461395264, 0.5, 1.5)),
		new DeathContract("usl3801", "SeraphimLandUnit", C("source_animadeath", 1, 1.3333333730697632, 1.0, 1.0)),
		new DeathContract("usl4004", "SeraphimLandUnit", C("source_animadeath01", 1, 4.0, 1.0, 1.0), C("source_animadeath02", 1, 4.0, 1.0, 1.0)),
		new DeathContract("usn1001", "SeraphimNavalUnit", C("source_animadeath01", 100, 23.33333396911621, 0.8, 1.2), C("source_animadeath02", 100, 23.33333396911621, 0.8, 1.2), C("source_animadeath03", 100, 23.33333396911621, 0.8, 1.2)),
		new DeathContract("usn2001", "SeraphimNavalUnit", C("source_animadeath01", 100, 26.66666603088379, 0.8, 1.2), C("source_animadeath02", 100, 26.66666603088379, 0.8, 1.2), C("source_animadeath03", 100, 26.66666603088379, 0.8, 1.2)),
		new DeathContract("usn2002", "SeraphimNavalUnit", C("source_animadeath01", 100, 31.66666603088379, null, null), C("source_animadeath02", 100, 31.66666603088379, null, null), C("source_animadeath03", 100, 31.66666603088379, null, null)),
		new DeathContract("usn3001", "SeraphimNavalUnit", C("source_animadeath01", 100, 33.33333206176758, 0.8, 1.2), C("source_animadeath02", 100, 33.33333206176758, 0.8, 1.2), C("source_animadeath03", 100, 23.366666793823242, 0.8, 1.2)),
		new DeathContract("usn3003", "SeraphimNavalUnit", C("source_animadeath01", 100, 33.33333206176758, 0.5, 1.5), C("source_animadeath02", 100, 33.33333206176758, 0.5, 1.5), C("source_animadeath03", 100, 33.33333206176758, 0.5, 1.5)),
		new DeathContract("uss1001", "SeraphimStructure", C("source_animadeath", 100, 2.3333332538604736, 1.0, 1.0)),
		new DeathContract("uss1201", "SeraphimStructure", C("source_animadeath", 100, 1.6666666269302368, 1.0, 1.0)),
		new DeathContract("uss1301", "SeraphimStructure", C("source_animadeath", 1, 8.666666984558105, 1.0, 1.0)),
		new DeathContract("uss1511", "SeraphimLandFactory", C("source_animadeath", 100, 5.0, 1.0, 1.0)),
		new DeathContract("uss1512", "SeraphimAirFactory", C("source_animadeath", 100, 5.0, 1.0, 1.0)),
		new DeathContract("uss1513", "SeraphimNavalFactory", C("source_animadeath", 100, 6.666666507720947, 1.0, 1.0)),
		new DeathContract("uss1601", "SeraphimAlloyExtractor", C("source_animadeath", 100, 1.0, 1.0, 1.0)),
		new DeathContract("uss1611", "SeraphimEnergyGenerator", C("source_animadeath", 100, 1.3333333730697632, 1.0, 1.0)),
		new DeathContract("uss1701", "SeraphimStructure", C("source_animadeath", 100, 2.0, 1.0, 1.0)),
		new DeathContract("uss1804", "SeraphimStructure", C("source_animadeath", 100, 1.6666666269302368, 0.5, 1.5)),
		new DeathContract("uss2001", "SeraphimStructure", C("source_animadeath", 100, 2.3333332538604736, 1.0, 1.0)),
		new DeathContract("uss2101", "SeraphimStructure", C("source_animadeath", 100, 1.6666666269302368, 1.0, 1.0)),
		new DeathContract("uss2102", "SeraphimStructure", C("source_animadeath", 100, 1.6666666269302368, 1.0, 1.0)),
		new DeathContract("uss2201", "SeraphimStructure", C("source_animadeath", 100, 2.0, 1.0, 1.0)),
		new DeathContract("uss2301", "SeraphimStructure", C("source_animadeath", 1, 8.333333015441895, 1.0, 1.0)),
		new DeathContract("uss2401", "SeraphimStructure", C("source_animadeath", 1, 1.0, null, null)),
		new DeathContract("uss2402", "SeraphimStructure", C("source_animadeath", 100, 1.6666666269302368, 1.0, 1.0)),
		new DeathContract("uss2510", "SeraphimStructure", C("source_animadeath", 1, 4.0, 1.0, 1.0)),
		new DeathContract("uss2511", "SeraphimLandFactory", C("source_animadeath", 100, 5.0, 1.0, 1.0)),
		new DeathContract("uss2512", "SeraphimAirFactory", C("source_animadeath", 100, 5.0, 1.0, 1.0)),
		new DeathContract("uss2513", "SeraphimNavalFactory", C("source_animadeath", 100, 6.666666507720947, 1.0, 1.0)),
		new DeathContract("uss2601", "SeraphimAlloyExtractor", C("source_animadeath", 100, 1.0, 1.0, 1.0)),
		new DeathContract("uss2611", "SeraphimEnergyGenerator", C("source_animadeath", 100, 3.3333332538604736, 1.0, 1.0)),
		new DeathContract("uss2701", "SeraphimStructure", C("source_animadeath", 100, 2.6666667461395264, 1.0, 1.0)),
		new DeathContract("uss2711", "SeraphimStructure", C("source_animadeath", 1, 1.5, 1.0, 1.0)),
		new DeathContract("uss3101", "SeraphimStructure", C("source_animadeath", 100, 5.0, 1.0, 1.0)),
		new DeathContract("uss3201", "SeraphimStructure", C("source_animadeath", 100, 2.5, 1.0, 1.0)),
		new DeathContract("uss3401", "SeraphimStructure", C("source_animadeath", 1, 1.0666667222976685, null, null)),
		new DeathContract("uss3501", "SeraphimEngineeringStation", C("source_animadeath", 1, 2.6666667461395264, 1.0, 1.0)),
		new DeathContract("uss3511", "SeraphimLandFactory", C("source_animadeath", 100, 4.0, 1.0, 1.0)),
		new DeathContract("uss3512", "SeraphimAirFactory", C("source_animadeath", 100, 5.0, 1.0, 1.0)),
		new DeathContract("uss3513", "SeraphimNavalFactory", C("source_animadeath", 100, 6.666666507720947, 1.0, 1.0)),
		new DeathContract("uss3601", "SeraphimAlloyExtractor", C("source_animadeath", 100, 1.0, 1.0, 1.0)),
		new DeathContract("uss3611", "SeraphimEnergyGenerator", C("source_animadeath", 100, 5.0, 1.0, 1.0)),
		new DeathContract("uss3701", "SeraphimStructure", C("source_animadeath", 100, 3.3333332538604736, 1.0, 1.0)),
		new DeathContract("uss4102", "SeraphimStructure", C("source_animadeath", 100, 4.666666507720947, 1.0, 1.0))
	};

	private static DeathClip C(string key, int weight, double duration, double? min = 1.0, double? max = 1.0)
	{
		return new DeathClip(key, weight, duration, min, max);
	}
}
