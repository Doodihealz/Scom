UnitTemplate = Import("scom/units/uga2301/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga2301", "SCOM unit identity mismatch: uga2301")
