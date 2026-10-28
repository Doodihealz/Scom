UnitTemplate = Import("scom/units/ucs1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1201", "SCOM unit identity mismatch: ucs1201")
