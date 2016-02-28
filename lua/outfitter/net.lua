local Tag='outfitter' 
local NTag = 'OF'

module(Tag,package.seeall)

function SetNeworked(o,w,pl)
	if CLIENT then pl = LocalPlayer() end
	local dat = EncodeOW(o,w)
	pl:SetNetData(NTag,dat)
end

if CLIENT then
	
	function NetData(plid,k,val)
		if k~=NTag then return end
		--local t = player.GetNetVarsTable()[plid]
		--assert(t)
		--t.outfitter_mdl,t.outfitter_wsid = DecodeOW(val)
		local pl = findpl(plid)
		dbg("netData",pl or plid,k,"<-",val)
		if pl then OnPlayerVisible(pl) end
	end
		
	function OnPlayerVisible(pl)
		
		-- check for changed outfit data
		local new = pl:GetNetData(NTag)
		local old = pl.outfitter_nvar

		if new~=old then
			pl.outfitter_nvar = new
			
			--if old == true then return end
			
			local mdl,wsid
			if new then
				mdl,wsid = DecodeOW(new)
			end
			
			dbg("OnPlayerVisible",pl==LocalPlayer() and "SKIP" or pl,mdl or "UNSET?",wsid)
			
			if pl==LocalPlayer() then
				return
			end
			
			OnChangeOutfit(pl,mdl,wsid)
		end
		
	end

	hook.Add("NetworkEntityCreated",Tag,function(pl) 
		if not pl:IsPlayer() then return end 
		OnPlayerVisible(pl) 
	end)

	local function OnPlayerPVS(pl,inpvs)
		if not inpvs then return end
		OnPlayerInPVS(pl)
	end
	
	hook.Add("NotifyShouldTransmit",Tag,function(pl,inpvs)
		if pl:IsPlayer() then
			OnPlayerPVS(pl,inpvs)
		end
	end)
	
	-- I want to tell others about my outfit
	function NetworkOutfit(mdl,wsid)
		assert(wsid and tonumber(wsid))
		local encoded = EncodeOW(mdl:gsub("%.mdl$",""),wsid)
		dbg("NetworkOutfit",mdl,wsid,('%q'):format(encoded))
		LocalPlayer():SetNetData(Tag,encoded)
	end	
	
end

hook.Add("NetData",Tag,function(...) return NetData(...) end)