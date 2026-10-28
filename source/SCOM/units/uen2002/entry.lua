UnitTemplate = Import("scom/units/uen2002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen2002", "SCOM unit identity mismatch: uen2002")
