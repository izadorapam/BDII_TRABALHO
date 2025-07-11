-- ==================================================
-- ====== TESTES DE COMPOSIÇÃO DE PRODUTOS ==========
-- ==================================================

-- TESTE 1: ADICIONAR COMPOSIÇÃO
SELECT ADICIONAR_COMPOSICAO_PRODUTO(3, 1, 2); -- ARRANJO DE ROSAS PRECISA DE 2 ROSAS

-- TESTE 2: VERIFICAR ESTOQUE PARA COMPOSIÇÃO
SELECT VERIFICAR_ESTOQUE_COMPOSICAO_RECURSIVO(3, 10); -- VERIFICA SE TEM 20 ROSAS

-- TESTE 3: MONTAR PRODUTO COMPOSTO
SELECT MONTAR_PRODUTO_COMPOSTO(3, 5); -- MONTA 5 ARRANJOS DE ROSAS