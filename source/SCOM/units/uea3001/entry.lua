UnitTemplate = Import("scom/units/uea3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea3001", "SCOM unit identity mismatch: uea3001")
