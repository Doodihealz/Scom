UnitTemplate = Import("scom/units/uss5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5002", "SCOM unit identity mismatch: uss5002")
