UnitTemplate = Import("scom/units/ugs5008/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5008", "SCOM unit identity mismatch: ugs5008")
