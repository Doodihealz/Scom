UnitTemplate = Import("scom/units/uss1601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1601", "SCOM unit identity mismatch: uss1601")
