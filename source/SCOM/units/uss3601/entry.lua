UnitTemplate = Import("scom/units/uss3601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3601", "SCOM unit identity mismatch: uss3601")
