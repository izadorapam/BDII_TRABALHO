-- ==================================================
-- ============ TESTES DE RELATÓRIOS ================
-- ==================================================

-- TESTE 1: PRODUTOS COM BAIXO ESTOQUE
SELECT * FROM PRODUTOS_BAIXO_ESTOQUE(10);
--OK
-- TESTE 2: PRODUTOS MAIS VENDIDOS
SELECT * FROM PRODUTOS_MAIS_VENDIDOS(5);
--OK

-- TESTE 3: VENDAS POR FUNCIONÁRIO
SELECT * FROM VENDAS_POR_FUNCIONARIO();
--OK