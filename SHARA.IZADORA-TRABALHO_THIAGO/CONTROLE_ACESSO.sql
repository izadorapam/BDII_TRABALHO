-- ==================================================
-- ================ CRIAÇÃO DE ROLES ================
-- ==================================================

-- ROLE PARA ADMINISTRADORES (ACESSO TOTAL)
CREATE ROLE FLOR_ADMINISTRADOR WITH LOGIN PASSWORD 'Admin@1234';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO FLOR_ADMINISTRADOR;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO FLOR_ADMINISTRADOR;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA PUBLIC TO FLOR_ADMINISTRADOR;

-- ROLE PARA GERENTES (ACESSO A QUASE TUDO, EXCETO DADOS SENSÍVEIS)
CREATE ROLE FLOR_GERENTE WITH LOGIN PASSWORD 'Gerente@1234';

-- PERMISSÕES EM TABELAS
GRANT SELECT, INSERT, UPDATE ON 
    PEDIDO, ITEM_PEDIDO, PRODUTO, COMPOSICAO_PRONTA, 
    CLIENTE, FORNECEDOR, COMPRA, ITEM_COMPRA
TO FLOR_GERENTE;

-- RESTRIÇÕES ESPECÍFICAS
REVOKE UPDATE ON CLIENTE, FUNCIONARIO FROM FLOR_GERENTE;

-- PERMISSÕES EM FUNÇÕES ESPECÍFICAS (NÃO TODAS)
GRANT EXECUTE ON FUNCTION 
    REGISTRAR_PEDIDO(INT, INT, VARCHAR, INT, INT, INT, DECIMAL, INT, INT, DECIMAL),
    CADASTRAR_CLIENTE(INT, VARCHAR, VARCHAR, VARCHAR, VARCHAR),
    ATUALIZAR_ESTOQUE(INT, INT),
    PRODUTOS_BAIXO_ESTOQUE(INT),
    VENDAS_POR_FUNCIONARIO()
TO FLOR_GERENTE;

-- PERMISSÕES EM VISUALIZAÇÕES
GRANT SELECT ON 
    VW_CLIENTES_ATIVOS, VW_PRODUTOS_ATIVOS, VW_PEDIDOS_ATIVOS, 
    VW_COMPRAS_ATIVAS, VW_FORNECEDORES_ATIVOS
TO FLOR_GERENTE;

-- ROLE PARA VENDEDORES (ACESSO LIMITADO)
CREATE ROLE FLOR_VENDEDOR WITH LOGIN PASSWORD 'Vendedor@1234';
GRANT SELECT, UPDATE ON PRODUTO TO FLOR_VENDEDOR;
GRANT SELECT, UPDATE ON COMPOSICAO_PRONTA TO FLOR_VENDEDOR;
GRANT SELECT, UPDATE ON PEDIDO TO FLOR_VENDEDOR;
GRANT SELECT ON VW_CLIENTES_ATIVOS, VW_PRODUTOS_ATIVOS TO FLOR_VENDEDOR;
GRANT SELECT, INSERT ON PEDIDO, ITEM_PEDIDO TO FLOR_VENDEDOR;
GRANT EXECUTE ON FUNCTION CADASTRAR_CLIENTE, REGISTRAR_PEDIDO TO FLOR_VENDEDOR;

-- ROLE PARA ESTOQUISTAS (ACESSO A PRODUTOS E COMPRAS)
CREATE ROLE FLOR_ESTOQUISTA WITH LOGIN PASSWORD 'Estoque@1234';
GRANT SELECT, INSERT, UPDATE ON PRODUTO, COMPRA, ITEM_COMPRA TO FLOR_ESTOQUISTA;
GRANT EXECUTE ON FUNCTION CADASTRAR_PRODUTO, ATUALIZAR_ESTOQUE, REGISTRAR_COMPRA TO FLOR_ESTOQUISTA;
GRANT SELECT ON VW_PRODUTOS_ATIVOS, VW_FORNECEDORES_ATIVOS TO FLOR_ESTOQUISTA;

-- ROLE PARA RELATÓRIOS (SOMENTE LEITURA)
CREATE ROLE FLOR_RELATORIOS WITH LOGIN PASSWORD 'Relatorios@1234';
GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO FLOR_RELATORIOS;
GRANT EXECUTE ON FUNCTION PRODUTOS_BAIXO_ESTOQUE, PRODUTOS_MAIS_VENDIDOS, VENDAS_POR_FUNCIONARIO TO FLOR_RELATORIOS;

SELECT ROLNAME FROM PG_ROLES;