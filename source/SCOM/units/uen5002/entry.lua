UnitTemplate = Import("scom/units/uen5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen5002", "SCOM unit identity mismatch: uen5002")
