UnitTemplate = Import("scom/units/uss3701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3701", "SCOM unit identity mismatch: uss3701")
