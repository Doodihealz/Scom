UnitTemplate = Import("scom/units/ugs1601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1601", "SCOM unit identity mismatch: ugs1601")
