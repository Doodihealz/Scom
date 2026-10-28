UnitTemplate = Import("scom/units/ucs3201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3201", "SCOM unit identity mismatch: ucs3201")
