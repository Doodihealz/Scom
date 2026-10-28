UnitTemplate = Import("scom/units/uca2701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca2701", "SCOM unit identity mismatch: uca2701")
