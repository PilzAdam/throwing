minetest.register_craftitem("throwing:arrow_rope", {
	description = "Rope Arrow",
	inventory_image = "throwing_arrow_rope.png",
})

minetest.register_node("throwing:arrow_rope_box", {
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
	tiles = {"throwing_arrow_rope.png", "throwing_arrow_rope.png", "throwing_arrow_rope_back.png", "throwing_arrow_rope_front.png", "throwing_arrow_rope_2.png", "throwing_arrow_rope.png"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"throwing:arrow_rope_box"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
	node = "",
}

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.env:get_node(pos)

	if self.timer>0.2 then
		local objs = minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 1)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				if obj:get_luaentity().name ~= "throwing:arrow_rope_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					if self.node ~= "" then
						minetest.env:place_node(self.lastpos, {name="vines:rope_block"})
					end
					self.object:remove()
				end
			else
				if self.node ~= "" then
					minetest.env:place_node(self.lastpos, {name="vines:rope_block"})
				end
				self.object:remove()
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" then
			if self.node ~= "" then
				minetest.env:place_node(self.lastpos, {name="vines:rope_block"})
			end
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("throwing:arrow_rope_entity", THROWING_ARROW_ENTITY)

minetest.register_craft({
	output = 'throwing:arrow_rope',
	recipe = {
		{'default:stick', 'default:stick', 'vines:rope_block'},
	}
})
