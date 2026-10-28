UnitTemplate = Import("scom/units/uss3611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3611", "SCOM unit identity mismatch: uss3611")
