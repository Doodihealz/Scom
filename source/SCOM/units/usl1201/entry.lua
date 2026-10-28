UnitTemplate = Import("scom/units/usl1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl1201", "SCOM unit identity mismatch: usl1201")
