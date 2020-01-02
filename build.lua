#!/usr/bin/env texlua
-- Execute with "l3build tag"

-- TODO -------------------------------------------------------------
-- ctan upload

-- Settings ----------------------------------------------------------
module = "tikzducks"

-- Package version ---------------------------------------------------
local handle = io.popen("git describe --tags $(git rev-list --tags --max-count=1)")
local oldtag = handle:read("*a")
handle:close()
newsubtag = string.sub(oldtag, 4)
newmajortag = string.sub(oldtag, 0, 3)
newsubtag = newsubtag + 1
packageversion = newmajortag .. math.floor(newsubtag)
print(packageversion)
--packageversion="v1.3"

-- Package date ------------------------------------------------------
packagedate = os.date("!%Y-%m-%d")
--packagedate = "2020-01-02"

-- Auto-versioning ---------------------------------------------------
function git(...)
    local args = {...}
    table.insert(args, 1, 'git')
    local cmd = table.concat(args, ' ')
    print('Executing:', cmd)
    os.execute(cmd)
end

tagfiles = {"*.sty", "*-doc.tex"}
function update_tag (file,content,tagname,tagdate)
	tagdate = string.gsub (packagedate,"-", "/")
	if string.match (file, "%.sty$" ) then
		content = string.gsub (
			content,
			"\\ProvidesPackage{(.-)}%[%d%d%d%d%/%d%d%/%d%d version v%d%.%d",
			"\\ProvidesPackage{%1}[" .. tagdate.." version "..packageversion
		)
		return content
	elseif string.match (file, "*-doc.tex$" ) then
		content = string.gsub (
			content,
			"\\date{Version v%d%.%d \\textendash{} %d%d%d%d%/%d%d%/%d%d",
			"\\date{Version " .. packageversion .. " \\textendash{} " .. tagdate
		)
		return content
	end
	return content
end

function tag_hook(tagname)
	git("add", "*.sty")
	git("add", "*-doc.tex")
	os.execute("latexmk " .. module .. "-doc")
	os.execute("cp " .. module .. "-doc.pdf documentation.pdf")
	git("add", "documentation.pdf")
	git("commit -m 'step version ", packageversion, "'" )
	git("tag", packageversion)
	print("tag" .. " " .. packageversion)
end