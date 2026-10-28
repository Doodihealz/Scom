UnitTemplate = Import("scom/units/usl4002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl4002", "SCOM unit identity mismatch: usl4002")
