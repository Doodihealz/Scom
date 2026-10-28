UnitTemplate = Import("scom/units/ugs1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1201", "SCOM unit identity mismatch: ugs1201")
