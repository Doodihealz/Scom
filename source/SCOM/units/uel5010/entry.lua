UnitTemplate = Import("scom/units/uel5010/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5010", "SCOM unit identity mismatch: uel5010")
