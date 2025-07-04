-- ==================================================
-- ============ TESTES DE REMOÇÃO ===================
-- ==================================================

-- TESTE 1: REMOÇÃO DE CLIENTE SEM PEDIDOS
SELECT REMOVER_CLIENTE(23);
-- TESTE COM CLIENTE COM PEDIDOS ATIVOS
SELECT REMOVER_CLIENTE(1);

-- TESTE 2: REMOÇÃO DE PRODUTO
SELECT REMOVER_PRODUTO(28);
-- TESTE COM PRODUTO EM PEDIDO ATIVO
SELECT REMOVER_PRODUTO(1);