UnitTemplate = Import("scom/units/usl2501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl2501", "SCOM unit identity mismatch: usl2501")
