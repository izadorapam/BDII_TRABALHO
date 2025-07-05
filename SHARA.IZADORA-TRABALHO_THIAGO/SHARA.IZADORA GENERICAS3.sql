-- ==================================================
--   ==== FUNÇÕES DE MANIPULAÇÃO GENÉRICA DE DADOS ====
-- ==================================================

CREATE OR REPLACE FUNCTION CADASTRAR_DADO(
    NOME_TABELA VARCHAR,
    COLUNAS VARCHAR,
    VALORES VARCHAR
) RETURNS TEXT AS $$
DECLARE
    RESULTADO TEXT;
    PARAMS TEXT[];
BEGIN
    -- Converter para minúsculas para comparação
    NOME_TABELA := LOWER(NOME_TABELA);
    
    -- Extrair os valores para array
    PARAMS := STRING_TO_ARRAY(VALORES, ',');
    
    BEGIN  -- Bloco BEGIN adicional para tratamento de exceções
        -- Chamar funções específicas quando existirem
        IF NOME_TABELA = 'cliente' THEN
            SELECT CADASTRAR_CLIENTE(
                PARAMS[1]::INT,       -- ID_CLIENTE
                TRIM(PARAMS[2]),      -- NOME
                TRIM(PARAMS[3]),      -- ENDERECO
                TRIM(PARAMS[4]),      -- TELEFONE
                TRIM(PARAMS[5])       -- EMAIL
            ) INTO RESULTADO;
            RETURN RESULTADO;
            
        ELSIF NOME_TABELA = 'funcionario' THEN
            SELECT CADASTRAR_FUNCIONARIO(
                PARAMS[1]::INT,       -- ID_FUNCIONARIO
                TRIM(PARAMS[2]),      -- NOME
                TRIM(PARAMS[3]),      -- TELEFONE
                TRIM(PARAMS[4]),      -- EMAIL
                TRIM(PARAMS[5])       -- CARGO
            ) INTO RESULTADO;
            RETURN RESULTADO;
            
        ELSIF NOME_TABELA = 'fornecedor' THEN
            SELECT CADASTRAR_FORNECEDOR(
                PARAMS[1]::INT,       -- ID_FORNECEDOR
                TRIM(PARAMS[2]),      -- NOME
                TRIM(PARAMS[3]),      -- TELEFONE
                TRIM(PARAMS[4])       -- EMAIL
            ) INTO RESULTADO;
            RETURN RESULTADO;
            
        ELSIF NOME_TABELA = 'produto' THEN
            SELECT CADASTRAR_PRODUTO(
                PARAMS[1]::INT,       -- ID_PRODUTO
                PARAMS[2]::INT,       -- ESTOQUE
                TRIM(PARAMS[3]),      -- NOME
                PARAMS[4]::DECIMAL,  -- PRECO
                TRIM(PARAMS[5]),      -- TIPO
                CASE WHEN PARAMS[6] IS NOT NULL THEN PARAMS[6]::INT ELSE NULL END -- ID_PRODUTO_COMPOE
            ) INTO RESULTADO;
            RETURN RESULTADO;
            
        ELSIF NOME_TABELA = 'pedido' THEN
            RETURN 'ERRO: USE A FUNÇÃO REGISTRAR_PEDIDO PARA CADASTRAR PEDIDOS';
            
        ELSIF NOME_TABELA = 'compra' THEN
            RETURN 'ERRO: USE A FUNÇÃO REGISTRAR_COMPRA PARA CADASTRAR COMPRAS';
            
        ELSE
            -- Fallback genérico para outras tabelas
            BEGIN
                EXECUTE 'INSERT INTO ' || NOME_TABELA || ' (' || COLUNAS || ') VALUES (' || VALORES || ')';
                RETURN 'SUCESSO: DADOS CADASTRADOS EM ' || NOME_TABELA;
            EXCEPTION WHEN OTHERS THEN
                RETURN 'ERRO: ' || SQLERRM;
            END;
        END IF;
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA CADASTRAR NESTA TABELA.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO EM CADASTRAR_DADO (TABELA: %): %', NOME_TABELA, SQLERRM;
            RETURN 'ERRO: FALHA AO CADASTRAR DADOS.';
    END;
END;
$$ LANGUAGE PLPGSQL;
-- --------------------------------------------------
CREATE OR REPLACE FUNCTION REMOVER_DADO(
    NOME_TABELA VARCHAR,
    COLUNA_ID VARCHAR,
    VALOR_ID VARCHAR
) RETURNS TEXT AS $$
DECLARE
    RESULTADO TEXT;
BEGIN
    -- Converter para minúsculas para comparação
    NOME_TABELA := LOWER(NOME_TABELA);
    
    -- Chamar funções específicas quando existirem
    IF NOME_TABELA = 'pedido' THEN
        SELECT REMOVER_PEDIDO(VALOR_ID::INT) INTO RESULTADO;
        RETURN RESULTADO;
        
    ELSIF NOME_TABELA = 'compra' THEN
        SELECT REMOVER_COMPRA(VALOR_ID::INT) INTO RESULTADO;
        RETURN RESULTADO;
        
    ELSIF NOME_TABELA = 'produto' THEN
        SELECT REMOVER_PRODUTO(VALOR_ID::INT) INTO RESULTADO;
        RETURN RESULTADO;
        
    ELSE
        -- Fallback genérico para outras tabelas
        BEGIN
            EXECUTE FORMAT('UPDATE %I SET ativo = FALSE WHERE %I = %L', 
                         NOME_TABELA, COLUNA_ID, VALOR_ID);
            RETURN 'SUCESSO: REGISTRO MARCADO COMO INATIVO';
        EXCEPTION WHEN OTHERS THEN
            RETURN 'ERRO: ' || SQLERRM;
        END;
    END IF;
END;
$$ LANGUAGE PLPGSQL;


-- --------------------------------------------------

CREATE OR REPLACE FUNCTION ALTERAR_DADO(
    NOME_TABELA VARCHAR,
    COLUNA_ID VARCHAR,
    VALOR_ID VARCHAR,
    DADOS_ALTERAR VARCHAR
) RETURNS TEXT AS $$
DECLARE
    RESULTADO TEXT;
    V_REGISTRO_EXISTE BOOLEAN;
BEGIN
    -- Converter para minúsculas para comparação
    NOME_TABELA := LOWER(NOME_TABELA);
    
    BEGIN  -- Bloco principal para tratamento de exceções
        -- Verificar se a tabela existe
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = NOME_TABELA) THEN
            RETURN 'ERRO: TABELA ' || NOME_TABELA || ' NÃO EXISTE.';
        END IF;

        -- Verificar se o registro existe
        EXECUTE 'SELECT EXISTS (SELECT 1 FROM ' || NOME_TABELA || ' WHERE ' || COLUNA_ID || ' = $1)' 
        USING VALOR_ID
        INTO V_REGISTRO_EXISTE;
        
        IF NOT V_REGISTRO_EXISTE THEN
            RETURN 'ERRO: REGISTRO NÃO ENCONTRADO NA TABELA ' || NOME_TABELA || '.';
        END IF;
        
        -- Chamar funções específicas quando existirem
        IF NOME_TABELA = 'produto' AND DADOS_ALTERAR LIKE 'ESTOQUE=%' THEN
            -- Se for atualização de estoque, usar função específica
            SELECT ATUALIZAR_ESTOQUE(
                VALOR_ID::INT,
                REGEXP_REPLACE(DADOS_ALTERAR, 'ESTOQUE=([0-9]+).*', '\1')::INT
            ) INTO RESULTADO;
            RETURN RESULTADO;
            
        ELSIF NOME_TABELA = 'cliente' THEN
            -- Função específica para cliente (se existir)
            RETURN 'ERRO: USE A FUNÇÃO ESPECÍFICA PARA ALTERAR CLIENTES';
            
        ELSIF NOME_TABELA = 'pedido' THEN
            RETURN 'ERRO: ATUALIZAÇÃO DE PEDIDOS DEVE SER FEITA DIRETAMENTE VIA TABELA';
            
        ELSIF NOME_TABELA = 'compra' THEN
            RETURN 'ERRO: ATUALIZAÇÃO DE COMPRAS DEVE SER FEITA DIRETAMENTE VIA TABELA';
            
        ELSE
            -- Fallback genérico para outras tabelas
            BEGIN
                EXECUTE FORMAT('UPDATE %I SET %s WHERE %I = %L', 
                             NOME_TABELA, DADOS_ALTERAR, COLUNA_ID, VALOR_ID);
                
                -- Verificar se alguma linha foi afetada
                IF NOT FOUND THEN
                    RETURN 'ERRO: NENHUM REGISTRO FOI ATUALIZADO.';
                END IF;
                
                RETURN 'SUCESSO: REGISTRO ATUALIZADO EM ' || NOME_TABELA || '.';
                
            EXCEPTION 
                WHEN OTHERS THEN
                    RAISE LOG 'ERRO AO ATUALIZAR DADO (TABELA: %, ID: %): %', 
                             NOME_TABELA, VALOR_ID, SQLERRM;
                    RETURN 'ERRO: FALHA NA ATUALIZAÇÃO DO REGISTRO. ' || SQLERRM;
            END;
        END IF;
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA ALTERAR ESTA TABELA.';
        WHEN SYNTAX_ERROR THEN
            RETURN 'ERRO: SINTAXE INVÁLIDA NOS DADOS DE ALTERAÇÃO.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO EM ALTERAR_DADO (TABELA: %, ID: %): %', 
                     NOME_TABELA, VALOR_ID, SQLERRM;
            RETURN 'ERRO: FALHA NA ATUALIZAÇÃO DO REGISTRO.';
    END;
END;
$$ LANGUAGE PLPGSQL;

------ Exemplo de uso
-- Atualização genérica
SELECT ALTERAR_DADO('cliente', 'id_cliente', '1', 'nome = ''Novo Nome''');

-- Atualização de estoque (chama ATUALIZAR_ESTOQUE)
SELECT ALTERAR_DADO('produto', 'id_produto', '5', 'estoque = 100');

-- Tentativa sem permissão (simulada)
SELECT ALTERAR_DADO('funcionario', 'id_funcionario', '2', 'cargo = ''Gerente''');
-- ==================================================
-- ==================================================
-- ==================================================
