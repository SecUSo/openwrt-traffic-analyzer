--[[
TrafficAnalyzer

Copyright 2015 Sebastian Fach <info at sebastian minus fach dot de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.trafficanalyzer", package.seeall)

function index()
	-- Main menu entry
	entry({"admin", "services", "trafficanalyzer"},
		alias("admin", "services", "trafficanalyzer", "rules"),
		_("TrafficAnalyzer"), 60)
	
	-- Tabs
	entry({"admin", "services", "trafficanalyzer", "rules"},
		cbi("trafficanalyzer/rules"),
		_("Rules"), 10).leaf = true

	entry({"admin", "services", "trafficanalyzer", "requestlog"},
		template("trafficanalyzer/requestlog"),
		_("Request Log"), 20).leaf = true
	
	entry({"admin", "services", "trafficanalyzer", "filterlog"},
		template("trafficanalyzer/filterlog"),
		_("Filter Log"), 30).leaf = true
		
	entry({"admin", "services", "trafficanalyzer", "setup"},
		template("trafficanalyzer/setup"),
		_("Setup"), 40).leaf = true
end
