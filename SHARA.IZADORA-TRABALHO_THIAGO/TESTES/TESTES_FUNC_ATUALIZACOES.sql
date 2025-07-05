-- ==================================================
-- ============ TESTES DE ATUALIZAÇÃO ===============
-- ==================================================

-- TESTE 1: ATUALIZAÇÃO DE ESTOQUE DIRETA VIA FUNÇÃO
SELECT ATUALIZAR_ESTOQUE(1, 150);
SELECT * FROM PRODUTO WHERE ID_PRODUTO = 1;

-- TESTE 2: ATUALIZAÇÃO DE ESTOQUE VIA COMPRA (USANDO FUNÇÃO REGISTRAR_COMPRA)
DO $$
DECLARE
    v_id_compra INT := 1000 + (RANDOM() * 9000)::INT; -- ID aleatório entre 1000-9999
    v_result TEXT;
BEGIN
    -- Verificar estoque antes
    RAISE NOTICE 'Estoque antes: %', (SELECT ESTOQUE FROM PRODUTO WHERE ID_PRODUTO = 1);
    
    -- Registrar compra com tratamento de erro detalhado
    v_result := REGISTRAR_COMPRA(
        P_ID_COMPRA => v_id_compra,
        P_ID_FORNECEDOR => 1,
        P_DATA => CURRENT_DATE,
        P_ID_FUNCIONARIO => 5,
        P_ID_PRODUTO1 => 1,
        P_QUANT1 => 10,
        P_VALOR1 => 8.00
    );
    
    RAISE NOTICE 'Resultado da compra: %', v_result;
    
    -- Verificar estoque depois
    RAISE NOTICE 'Estoque depois: %', (SELECT ESTOQUE FROM PRODUTO WHERE ID_PRODUTO = 1);
    
    -- Limpeza (se necessário)
    IF v_result LIKE 'SUCESSO%' THEN
        EXECUTE 'DELETE FROM ITEM_COMPRA WHERE ID_COMPRA = ' || v_id_compra;
        EXECUTE 'DELETE FROM COMPRA WHERE ID_COMPRA = ' || v_id_compra;
        RAISE NOTICE 'Dados de teste limpos';
    END IF;
END $$;
-- OK

-- TESTE 3: ATUALIZAÇÃO DE ESTOQUE VIA PEDIDO (USANDO FUNÇÃO REGISTRAR_PEDIDO)
-- Primeiro, verificar estoque atual
SELECT ESTOQUE FROM PRODUTO WHERE ID_PRODUTO = 1;

-- TESTE 3.1: PEDIDO VÁLIDO (ESTOQUE SUFICIENTE)
SELECT REGISTRAR_PEDIDO(
    P_ID_PEDIDO => 1010,
    P_ID_CLIENTE => 1,
    P_TELEFONE => '86999990001',
    P_ID_FUNCIONARIO => 1,
    P_ID_PRODUTO1 => 2,
    P_QUANT1 => 5,  -- Quantidade menor que estoque
    P_VALOR1 => 10.90
);

-- Verificar estoque após pedido (deve ter diminuído em 5 unidades)
SELECT * FROM PRODUTO WHERE ID_PRODUTO = 1;
-- OK

-- TESTE 3.2: PEDIDO INVÁLIDO (ESTOQUE INSUFICIENTE) - DEVE FALHAR
SELECT REGISTRAR_PEDIDO(
    P_ID_PEDIDO => 1008,
    P_ID_CLIENTE => 2,
    P_TELEFONE => '86999990002',
    P_ID_FUNCIONARIO => 2,
    P_ID_PRODUTO1 => 1,
    P_QUANT1 => 1000,  -- Quantidade maior que estoque
    P_VALOR1 => 10.90
);
--OK

-- Verificar que o estoque NÃO foi alterado
SELECT * FROM PRODUTO WHERE ID_PRODUTO = 1;

-- Limpar dados de teste
SELECT REMOVER_DADO('PEDIDO', 'ID_PEDIDO', '1010');

-- Limpeza segura de pedido de teste

SELECT REMOVER_DADO('PEDIDO', 'ID_PEDIDO', '1007');
SELECT * FROM PEDIDO

-------------------------------------------------------------------------

