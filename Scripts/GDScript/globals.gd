extends Node

# ==========================================
# OPÇÕES
# ==========================================

var cutscenes_disabled: bool = false
var controles_enabled: bool = true
var tutoriais_enabled: bool = true
var legendas_enabled: bool = true


# ==========================================
# MOEDAS E PONTOS
# ==========================================

var coins := 0
var score := 0


# ==========================================
# ONDAS
# ==========================================

var wave := 1

# Quantos inimigos precisam ser derrotados nesta onda
var total_enemies := 0

# Quantos ainda faltam derrotar
var enemies_remaining := 0

# Quantos estão vivos na cena
var enemies_alive := 0


# ==========================================
# BATALHA FINAL
# ==========================================

# Fase atual da batalha
# 1 = Dash
# 2 = Dash + Espinhos
# 3 = Dash + Espinhos + Laser
# 4 = Dash + Espinhos + Laser juntos
# 5 = Tudo mais rápido
var final_boss_phase: int = 1


# ==========================================
# HP DO BOSS
# ==========================================

var final_boss_hp: int = 10000
var final_boss_max_hp: int = 10000


# ==========================================
# ID DOS ATAQUES
# ==========================================

# ID do espinho atualmente escolhido
# -1 = nenhum
var final_boss_spike_id: int = -1

# ID do laser atualmente escolhido
# -1 = nenhum
var final_boss_laser_id: int = -1
