minetest.register_craftitem("throwing:arrow_fire", {
	description = "Fire Arrow",
	inventory_image = "throwing_arrow_fire.png",
})

minetest.register_node("throwing:arrow_fire_box", {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6/16, -1/16, -1/16, 7/16, 1/16, 1/16},
			--Spitze
			{-7/16, -1/16, -1/16, -6/16, 1/16, 1/16},
			--Federn
			{7/16, 0/16, 1/16, 8/16, 0/16, 2/16},
			{7/16, 0/16, -1/16, 8/16, 0/16, -2/16},
			{7/16, 1/16, 0/16, 8/16, 2/16, 0/16},
			{7/16, -1/16, 0/16, 8/16, -2/16, 0/16},
		}
	},
	tiles = {"throwing_arrow_fire.png", "throwing_arrow_fire.png", "throwing_arrow_fire_back.png", "throwing_arrow_fire_front.png", "throwing_arrow_fire_2.png", "throwing_arrow_fire.png"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"throwing:arrow_fire_box"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.env:get_node(pos)

	if self.timer>0.2 then
		local objs = minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				if obj:get_luaentity().name ~= "throwing:arrow_fire_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					local damage = 5
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						groupcaps={
							fleshy={times={[1]=1/(damage-2), [2]=1/(damage-1), [3]=1/damage}},
							snappy={times={[1]=1/(damage-2), [2]=1/(damage-1), [3]=1/damage}},
						}
					}, nil)
					self.object:remove()
				end
			else
				local damage = 5
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					groupcaps={
						fleshy={times={[1]=1/(damage-2), [2]=1/(damage-1), [3]=1/damage}},
						snappy={times={[1]=1/(damage-2), [2]=1/(damage-1), [3]=1/damage}},
					}
				}, nil)
				self.object:remove()
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" and node.name ~= "throwing:light" then
			minetest.env:set_node(self.lastpos, {name="fire:basic_flame"})
			self.object:remove()
		end
		if math.floor(self.lastpos.x+0.5) ~= math.floor(pos.x+0.5) or math.floor(self.lastpos.y+0.5) ~= math.floor(pos.y+0.5) or math.floor(self.lastpos.z+0.5) ~= math.floor(pos.z+0.5) then
			if minetest.env:get_node(self.lastpos).name == "throwing:light" then
				minetest.env:remove_node(self.lastpos)
			end
			if minetest.env:get_node(pos).name == "air" then
				minetest.env:set_node(pos, {name="throwing:light"})
			end
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("throwing:arrow_fire_entity", THROWING_ARROW_ENTITY)

minetest.register_craft({
	output = 'throwing:arrow_fire 4',
	recipe = {
		{'default:stick', 'default:stick', 'bucket:bucket_lava'},
	},
	replacements = {
		{"bucket:bucket_lava", "bucket:bucket_empty"}
	}
})

minetest.register_node("throwing:light", {
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {"throwing_empty.png"},
	light_source = LIGHT_MAX-4,
	selection_box = {
		type = "fixed",
		fixed = {
			{0,0,0,0,0,0}
		}
	},
	groups = {not_in_creative_inventory=1}
})

minetest.register_abm({
	nodenames = {"throwing:light"},
	interval = 10,
	chance = 1,
	action = function(pos, node)
		minetest.env:remove_node(pos)
	end
})
