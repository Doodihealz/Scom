UnitTemplate = Import("scom/units/uca1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca1701", "SCOM unit identity mismatch: uca1701")
