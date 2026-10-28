UnitTemplate = Import("scom/units/usl5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl5002", "SCOM unit identity mismatch: usl5002")
