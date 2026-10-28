UnitTemplate = Import("scom/units/uel5004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5004", "SCOM unit identity mismatch: uel5004")
