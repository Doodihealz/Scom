UnitTemplate = Import("scom/units/uel1002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel1002", "SCOM unit identity mismatch: uel1002")
