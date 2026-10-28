UnitTemplate = Import("scom/units/uen5003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen5003", "SCOM unit identity mismatch: uen5003")
