UnitTemplate = Import("scom/units/uel0000/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel0000", "SCOM unit identity mismatch: uel0000")
