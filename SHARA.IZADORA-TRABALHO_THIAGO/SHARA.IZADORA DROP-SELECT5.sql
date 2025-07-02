-- ==================================================
-- ================ COMANDOS DROP VIEW ==============
-- ==================================================

DROP VIEW IF EXISTS VW_CLIENTES_ATIVOS;
DROP VIEW IF EXISTS VW_FUNCIONARIOS_ATIVOS;
DROP VIEW IF EXISTS VW_FORNECEDORES_ATIVOS;
DROP VIEW IF EXISTS VW_PRODUTOS_ATIVOS;
DROP VIEW IF EXISTS VW_PEDIDOS_ATIVOS;
DROP VIEW IF EXISTS VW_ITENS_PEDIDO_ATIVOS;
DROP VIEW IF EXISTS VW_COMPRAS_ATIVAS;
DROP VIEW IF EXISTS VW_ITENS_COMPRA_ATIVOS;
DROP VIEW IF EXISTS VW_COMPOSICOES_ATIVAS;

-- ==================================================
-- ================ COMANDOS DROP TABLE =============
-- ==================================================

DROP TABLE IF EXISTS ITEM_COMPRA;
DROP TABLE IF EXISTS COMPRA;
DROP TABLE IF EXISTS ITEM_PEDIDO;
DROP TABLE IF EXISTS PEDIDO;
DROP TABLE IF EXISTS COMPOSICAO_PRONTA;
DROP TABLE IF EXISTS PRODUTO;
DROP TABLE IF EXISTS FORNECEDOR;
DROP TABLE IF EXISTS FUNCIONARIO;
DROP TABLE IF EXISTS CLIENTE;

-- ==================================================
-- ================ COMANDOS SELECT ALL TABLES ======
-- ==================================================

SELECT * FROM CLIENTE;
SELECT * FROM FUNCIONARIO;
SELECT * FROM FORNECEDOR;
SELECT * FROM PRODUTO;
SELECT * FROM PEDIDO;
SELECT * FROM ITEM_PEDIDO;
SELECT * FROM COMPRA;
SELECT * FROM ITEM_COMPRA;
SELECT * FROM COMPOSICAO_PRONTA;

-- ==================================================
-- ================ COMANDOS SELECT ALL VIEWS =======
-- ==================================================

SELECT * FROM VW_CLIENTES_ATIVOS;
SELECT * FROM VW_FUNCIONARIOS_ATIVOS;
SELECT * FROM VW_FORNECEDORES_ATIVOS;
SELECT * FROM VW_PRODUTOS_ATIVOS;
SELECT * FROM VW_PEDIDOS_ATIVOS;
SELECT * FROM VW_ITENS_PEDIDO_ATIVOS;
SELECT * FROM VW_COMPRAS_ATIVAS;
SELECT * FROM VW_ITENS_COMPRA_ATIVOS;
SELECT * FROM VW_COMPOSICOES_ATIVAS;

-- ==================================================
-- ==================================================
-- ==================================================
