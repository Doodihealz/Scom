UnitTemplate = Import("scom/units/ucs1301/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1301", "SCOM unit identity mismatch: ucs1301")
