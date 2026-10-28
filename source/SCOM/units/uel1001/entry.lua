UnitTemplate = Import("scom/units/uel1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel1001", "SCOM unit identity mismatch: uel1001")
