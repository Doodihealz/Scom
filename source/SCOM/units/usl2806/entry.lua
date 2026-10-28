UnitTemplate = Import("scom/units/usl2806/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl2806", "SCOM unit identity mismatch: usl2806")
