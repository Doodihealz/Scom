UnitTemplate = Import("scom/units/ucs1501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1501", "SCOM unit identity mismatch: ucs1501")
