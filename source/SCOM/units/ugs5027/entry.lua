UnitTemplate = Import("scom/units/ugs5027/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5027", "SCOM unit identity mismatch: ugs5027")
