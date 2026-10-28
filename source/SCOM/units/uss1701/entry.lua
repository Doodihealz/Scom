UnitTemplate = Import("scom/units/uss1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1701", "SCOM unit identity mismatch: uss1701")
