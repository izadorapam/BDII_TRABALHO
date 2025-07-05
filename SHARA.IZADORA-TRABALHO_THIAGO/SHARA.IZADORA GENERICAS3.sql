-- ==================================================
--   ==== FUNÇÕES DE MANIPULAÇÃO GENÉRICA DE DADOS ====
-- ==================================================

CREATE OR REPLACE FUNCTION CADASTRAR_DADO(
    NOME_TABELA VARCHAR,
    COLUNAS VARCHAR,
    VALORES VARCHAR
) RETURNS TEXT AS $$
DECLARE
    COMANDO_SQL TEXT;
BEGIN
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = LOWER(NOME_TABELA)) THEN
            RETURN 'ERRO: TABELA ' || NOME_TABELA || ' NÃO EXISTE.';
        END IF;
        
        COMANDO_SQL := 'INSERT INTO ' || NOME_TABELA || ' (' || COLUNAS || ') VALUES (' || VALORES || ')';
        
        EXECUTE COMANDO_SQL;
        
        RETURN 'SUCESSO: DADOS CADASTRADOS EM ' || NOME_TABELA;
        
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
    COMANDO_SQL TEXT;
    REGISTRO_EXISTE BOOLEAN;
BEGIN
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = LOWER(NOME_TABELA)) THEN
            RETURN 'ERRO: TABELA NÃO ENCONTRADA.';
        END IF;

        EXECUTE 'SELECT EXISTS (SELECT 1 FROM ' || NOME_TABELA || ' WHERE ' || COLUNA_ID || ' = ''' || VALOR_ID || ''')' 
        INTO REGISTRO_EXISTE;
        
        IF NOT REGISTRO_EXISTE THEN
            RETURN 'ERRO: REGISTRO NÃO ENCONTRADO.';
        END IF;
        
        COMANDO_SQL := 'UPDATE ' || NOME_TABELA || ' SET ' || DADOS_ALTERAR || 
                      ' WHERE ' || COLUNA_ID || ' = ''' || VALOR_ID || '''';
        
        EXECUTE COMANDO_SQL;
        
        RETURN 'REGISTRO ATUALIZADO COM SUCESSO.';
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA ALTERAR ESTA TABELA.';
        WHEN SYNTAX_ERROR THEN
            RETURN 'ERRO: SINTAXE INVÁLIDA NOS DADOS DE ALTERAÇÃO.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO AO ALTERAR DADO (TABELA: %, ID: %): %', NOME_TABELA, VALOR_ID, SQLERRM;
            RETURN 'ERRO: FALHA NA ATUALIZAÇÃO DO REGISTRO.';
    END;
END;
$$ LANGUAGE PLPGSQL;
-- ==================================================
-- ==================================================
-- ==================================================
