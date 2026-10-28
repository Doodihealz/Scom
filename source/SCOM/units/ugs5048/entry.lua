UnitTemplate = Import("scom/units/ugs5048/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5048", "SCOM unit identity mismatch: ugs5048")
