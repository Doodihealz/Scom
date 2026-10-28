UnitTemplate = Import("scom/units/uca3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca3001", "SCOM unit identity mismatch: uca3001")
