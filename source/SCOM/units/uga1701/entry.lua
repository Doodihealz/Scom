UnitTemplate = Import("scom/units/uga1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga1701", "SCOM unit identity mismatch: uga1701")
