UnitTemplate = Import("scom/units/uea1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea1201", "SCOM unit identity mismatch: uea1201")
