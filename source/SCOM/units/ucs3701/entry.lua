UnitTemplate = Import("scom/units/ucs3701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3701", "SCOM unit identity mismatch: ucs3701")
