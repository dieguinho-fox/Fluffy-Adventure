local worldselectionativo = {
	extends = Node,
	estado_anterior = nil
}

function worldselectionativo:_process(delta)
	local root = self:get_tree():get_root()
	local node = root:find_child("worldselection", true, false)

	if not node then
		return
	end

	local atual = node.visible

	if self.estado_anterior == nil or self.estado_anterior ~= atual then
		if atual then
			print("[DEBUG] seleção de mundo está ativo")
		else
			print("[DEBUG] seleção de mundo foi fechado")
		end

		self.estado_anterior = atual
	end
end

return worldselectionativo
