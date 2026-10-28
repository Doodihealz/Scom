UnitTemplate = Import("scom/units/uss1804/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1804", "SCOM unit identity mismatch: uss1804")
