UnitTemplate = Import("scom/units/ugs3701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3701", "SCOM unit identity mismatch: ugs3701")
