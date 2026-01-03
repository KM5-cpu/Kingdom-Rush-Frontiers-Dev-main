-- chunkname: @./kr2/game_overrides.lua

local E = require("entity_db")
local i18n = require("i18n")

function KWindow:set_responder(v)
	local c = self.responder

	if c then
		self.responder = nil

		if c.on_responded then
			c:on_responded()
		end
	end

	if v then
		self.responder = v

		if v.on_respond then
			v:on_respond()
		end
	end
end

function E:patch_templates(balance)
	self.balance = {}
	if balance then
		self:balance_templates(require("balance." .. balance))
	end
end

function E:balance_templates(balance)
	if balance then
		for name, template in pairs(self.entities) do
			if balance[name] then
				if not self.balance[name] then
					self.balance[name] = table.deepclone(template)
				end
				table.deepmerge(template, balance[name])
			end
		end
	else
		table.deepmerge(self.entities, self.balance)
	end
end

function i18n:ft(name, ...)
	self.msgs[self.current_locale][name] = string.format(self.msgs[self.current_locale][name], ...)
end

function i18n:patch_strings()
	package.loaded["strings." .. self.current_locale] = nil

	for n, s in pairs(require("strings." .. self.current_locale)) do
		self.msgs[self.current_locale][n] = string.gsub(s, "%%{(.-)}", function(f)
			local t = E.entities
			for k in string.gmatch(f, "[%w_]+") do
				k = tonumber(k) or k
				if t[k] then
					t = t[k]
				else
					t = ""
					break
				end
			end
			return t
		end)
	end
end
