--[[
TrafficAnalyzer

Copyright 2015 Sebastian Fach <info at sebastian minus fach dot de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.tools.webadmin")
require("uci")

cursor = uci.cursor()

m = Map("trafficanalyzer",
	translate("TrafficAnalyzer - Rules"),
	translate("TrafficAnalyzer is a rule-based traffic filter for detecting and blocking unencrypted transmission of private data (e.g. passwords). For filtering and blocking the proxy privoxy is used (http://www.privoxy.org)."))

--Filter rules
s = m:section(TypedSection, "filter", translate("Filters"), translate("Filters are normal privoxy-filters. Syntax description can be found at http://www.privoxy.org/user-manual/filter-file.html."))
s.addremove = true
s.anonymous = true
s.sortable = true
s.template  = "cbi/tblsection"

enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.default = "1"
enabled.rmempty = false
enabled.size = "5%"

type = s:option(Value, "type", translate("Type"))
type.datatype = "string"
type.rmempty = false
type.size = "10%"

name = s:option(Value, "name", translate("Name"))
name.datatype = "string"
name.rmempty = false
name.size = "10%"

description = s:option(Value, "description", translate("Description"))
description.datatype = "string"
description.rmempty = true
description.size = "20%"

pattern = s:option(Value, "pattern", translate("Pattern"))
pattern.datatype = "string"
pattern.rmempty = false
pattern.size = "20%"

comment = s:option(Value, "comment", translate("Comment"))
comment.datatype = "string"
comment.rmempty = true
comment.size = "20%"

--Actions
s = m:section(TypedSection, "action", translate("Actions"), translate("Description for the actions can be found at http://www.privoxy.org/user-manual/actions-file.html"))
s.addremove = true
s.anonymous = true
s.sortable = true
s.template  = "cbi/tblsection"

enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.default = "1"
enabled.rmempty = false
enabled.size = "5%"

type = s:option(Value, "type", translate("Type"))
type.datatype = "string"
type.rmempty = false
type.size = "10%"

description = s:option(Value, "description", translate("Description"))
description.datatype = "string"
description.rmempty = true
description.size = "20%"

pattern = s:option(Value, "pattern", translate("Pattern"))
pattern.datatype = "string"
pattern.rmempty = false
pattern.size = "20%"

comment = s:option(Value, "comment", translate("Comment"))
comment.datatype = "string"
comment.rmempty = true
comment.size = "20%"

-- Hook for custom processing when data is saved
function m.on_commit(self)
	write_filters()
	write_actions()
end

function m.on_after_commit(self)
	luci.sys.exec("/etc/init.d/privoxy restart")
end

-- Writes the filters in privoxies' old config file format
-- Note: This might be removed when privoxy supports uci
function write_filters()
	file = io.open("/etc/privoxy/trafficanalyzer.filter", "w+")

	file:write("##################################################################################################\n")
	file:write("# Note: This file is automatically created by the traffic analyzer and will be overridden each   #\n")
	file:write("# time the 'on_commit' hook is called in '/usr/lib/lua/luci/model/cbi/trafficanalyzer/rules.lua' #\n")
	file:write("##################################################################################################\n")
	
	cursor:foreach("trafficanalyzer", "filter", write_filter_item)
	
	file:flush()
	file:close()
end

-- Helper function for 'write_filters'
function write_filter_item(item)
	if (item["enabled"] ~= "0") and (item["type"] ~= nil) and (item["name"] ~= nil) and (item["pattern"] ~= nil) then
		file:write("\n" .. item["type"] .. ": " .. item["name"])
		if item["description"] ~= nil then
			file:write(" " .. item["description"])
		end
		file:write("\n")
		if item["comment"] ~= nil then
			file:write("# " .. item["comment"] .. "\n")
		end
		file:write(item["pattern"] .. "\n")
	end
end

-- Writes the actions in privoxies' old config file format
-- Note: This might be removed when privoxy supports uci
function write_actions()
	file = io.open("/etc/privoxy/trafficanalyzer.action", "w+")

	file:write("##################################################################################################\n")
	file:write("# Note: This file is automatically created by the traffic analyzer and will be overridden each   #\n")
	file:write("# time the 'on_commit' hook is called in '/usr/lib/lua/luci/model/cbi/trafficanalyzer/rules.lua' #\n")
	file:write("##################################################################################################\n")
	
	file:write("\n{")
	cursor:foreach("trafficanalyzer", "filter", write_filter_in_actionfile)
	file:write("}\n/.\n")

	cursor:foreach("trafficanalyzer", "action", write_action_item)
	
	file:flush()
	file:close()
end

-- Helper function for 'write_actions'
function write_filter_in_actionfile(item)
	if (item["enabled"] ~= "0") and (item["name"] ~= nil) then
		if item[".index"] ~= 0 then
			file:write(" \\\n")
		end
		file:write("+filter{" .. item["name"] .. "}")
	end
end

-- Helper function for 'write_actions'
function write_action_item(item)
	if (item["enabled"] ~= "0") and (item["type"] ~= nil) and (item["description"] ~= nil) and (item["pattern"] ~= nil) then
		file:write("\n")
		if item["comment"] ~= nil then
			file:write("# " .. item["comment"] .. "\n")
		end
		file:write("{" .. item["type"] .. "{" .. item["description"] .. "}}\n")
		file:write(item["pattern"] .. "\n")
	end
end

return m
