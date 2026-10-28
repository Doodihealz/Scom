UnitTemplate = Import("scom/units/ucs1601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1601", "SCOM unit identity mismatch: ucs1601")
