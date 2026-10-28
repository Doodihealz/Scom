UnitTemplate = Import("scom/units/uel3002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel3002", "SCOM unit identity mismatch: uel3002")
