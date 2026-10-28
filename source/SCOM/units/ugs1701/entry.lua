UnitTemplate = Import("scom/units/ugs1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1701", "SCOM unit identity mismatch: ugs1701")
