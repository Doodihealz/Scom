UnitTemplate = Import("scom/units/ugs2701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2701", "SCOM unit identity mismatch: ugs2701")
