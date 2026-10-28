UnitTemplate = Import("scom/units/uga3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga3001", "SCOM unit identity mismatch: uga3001")
