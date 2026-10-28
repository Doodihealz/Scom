UnitTemplate = Import("scom/units/ugs5021/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5021", "SCOM unit identity mismatch: ugs5021")
