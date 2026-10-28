UnitTemplate = Import("scom/units/uca2301/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca2301", "SCOM unit identity mismatch: uca2301")
