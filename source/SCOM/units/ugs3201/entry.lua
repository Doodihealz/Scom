UnitTemplate = Import("scom/units/ugs3201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3201", "SCOM unit identity mismatch: ugs3201")
