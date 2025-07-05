-- ==================================================
-- ============ TESTES DE REMOÇÃO ===================
-- ==================================================

-- TESTE 1: REMOÇÃO DE CLIENTE SEM PEDIDOS
SELECT REMOVER_CLIENTE(202);
--OK
-- TESTE COM CLIENTE COM PEDIDOS ATIVOS
SELECT REMOVER_CLIENTE(1);
--OK

-- TESTE 2: REMOÇÃO DE PRODUTO
SELECT REMOVER_PRODUTO(28);
--OK
-- TESTE COM PRODUTO EM PEDIDO ATIVO
SELECT REMOVER_PRODUTO(1);
--OK
SELECT * FROM PRODUTO;

SELECT * FROM CLIENTE;