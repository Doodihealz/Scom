UnitTemplate = Import("scom/units/ugs5018/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5018", "SCOM unit identity mismatch: ugs5018")
