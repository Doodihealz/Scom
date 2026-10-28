UnitTemplate = Import("scom/units/ugs5045/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5045", "SCOM unit identity mismatch: ugs5045")
