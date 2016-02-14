vers 11.2

matamac
matainclude DoFileWriter List

mata:

void write_other_labs(`DoFileWriterS' df, `SR' otherlists, `SS' other)
{
	`SS' otherval

	df.put(`"* Add "other" values to value labels that need them."')
	df.put("local otherlabs " + invtokens(otherlists))
	df.put("foreach lab of local otherlabs {")
	df.put(`"mata: st_vlload("\`lab'", \`values' = ., \`text' = "")"')
	if (other == "max" | other == "min") {
		df.put(sprintf(`"mata: st_local("otherval", "' +
			`"strofreal(%s, "%s"))"',
			(other == "max" ? "max(\`values') + 1" : "min(\`values') - 1"),
			`RealFormat'))
		otherval = "\`otherval'"
	}
	else
		otherval = other
	df.put("local othervals \`othervals' " + otherval)
	df.put(sprintf("label define \`lab' %s other, add", otherval))
	df.put("}")
	df.put("")
}

void write_save_label_info(`DoFileWriterS' df)
{
	df.put("* Save label information.")
	df.put("label dir")
	df.put("local labs \`r(names)'")
	df.put("foreach lab of local labs {")
	df.put("quietly label list \`lab'")
	df.put(`"* "nassoc" for "number of associations""')
	df.put("local nassoc \`nassoc' \`r(k)'")
	df.put("}")
	df.put("")
}

void write_encode_start(`DoFileWriterS' df, `SS' strlists, `SS' listnamechar,
	`SS' isotherchar)
{
	df.put("* Encode fields whose list contains a noninteger name.")
	df.put("local lists " + strlists)
	df.put("tempvar temp")
	df.put(sprintf("ds, has(char %s)", listnamechar))
	df.put("foreach var in \`r(varlist)' {")
	df.put(sprintf("local list : char \`var'[%s]", listnamechar))
	df.put(sprintf("if \`:list list in lists' & !\`:char \`var'[%s]' {",
		isotherchar))
	df.put("capture confirm numeric variable \`var'")
	df.put("if !_rc {")
	df.put(sprintf("tostring \`var', replace format(%s)", `RealFormat'))
	df.put("if !\`:list list in sysmisslabs' ///")
	df.put(`"replace \`var' = "" if \`var' == ".""')
	df.put("}")
	df.put("generate \`temp' = \`var'")
	df.put("")
}

void write_encode_end(`DoFileWriterS' df)
{
	df.put("replace \`var' = \`temp'")
	df.put("drop \`temp'")
	df.put("encode \`var', gen(\`temp') label(\`list') noextend")
	df.put("move \`temp' \`var'")
	df.put("foreach char in \`:char \`var'[]' {")
	df.put(`"mata: st_global("\`temp'[\`char']", "' +
		`"st_global("\`var'[\`char']"))"')
	df.put("}")
	df.put("drop \`var'")
	df.put("rename \`temp' \`var'")
	df.put("}")
	df.put("}")
	df.put("")
}

end
