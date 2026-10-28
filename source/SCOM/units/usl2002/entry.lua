UnitTemplate = Import("scom/units/usl2002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl2002", "SCOM unit identity mismatch: usl2002")
