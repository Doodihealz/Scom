UnitTemplate = Import("scom/units/uel3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel3001", "SCOM unit identity mismatch: uel3001")
