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
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = LOWER(NOME_TABELA)) THEN
        RETURN 'ERRO: TABELA ' || NOME_TABELA || ' NÃO EXISTE.';
    END IF;
    
    COMANDO_SQL := 'INSERT INTO ' || NOME_TABELA || ' (' || COLUNAS || ') VALUES (' || VALORES || ')';
    
    BEGIN
        EXECUTE COMANDO_SQL;
        RETURN 'SUCESSO: DADOS CADASTRADOS EM ' || NOME_TABELA;
    EXCEPTION WHEN OTHERS THEN
        RETURN 'ERRO AO CADASTRAR: VERIFIQUE OS VALORES. DETALHES: ' || SQLERRM;
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
    COMANDO_SQL TEXT;
    REGISTRO_EXISTE BOOLEAN;
    TABELA_TEM_ATIVO BOOLEAN;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = LOWER(NOME_TABELA)) THEN
        RETURN 'ERRO: TABELA ' || NOME_TABELA || ' NÃO EXISTE.';
    END IF;
    
    EXECUTE 'SELECT EXISTS (SELECT 1 FROM ' || NOME_TABELA || ' WHERE ' || COLUNA_ID || ' = ''' || VALOR_ID || ''')' INTO REGISTRO_EXISTE;
    
    IF NOT REGISTRO_EXISTE THEN
        RETURN 'ERRO: REGISTRO NÃO ENCONTRADO.';
    END IF;
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = LOWER(NOME_TABELA) AND column_name = 'ativo'
    ) INTO TABELA_TEM_ATIVO;
    
    IF TABELA_TEM_ATIVO THEN
        COMANDO_SQL := 'UPDATE ' || NOME_TABELA || ' SET ATIVO = FALSE WHERE ' || COLUNA_ID || ' = ''' || VALOR_ID || '''';
    ELSE
        COMANDO_SQL := 'DELETE FROM ' || NOME_TABELA || ' WHERE ' || COLUNA_ID || ' = ''' || VALOR_ID || '''';
    END IF;
    
    BEGIN
        EXECUTE COMANDO_SQL;
        
        IF TABELA_TEM_ATIVO THEN
            RETURN 'SUCESSO: REGISTRO MARCADO COMO INATIVO EM ' || NOME_TABELA;
        ELSE
            RETURN 'SUCESSO: REGISTRO REMOVIDO DE ' || NOME_TABELA;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN 'ERRO AO REMOVER: ' || SQLERRM;
    END;
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
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = LOWER(NOME_TABELA)) THEN
        RETURN 'ERRO: TABELA ' || NOME_TABELA || ' NÃO EXISTE.';
    END IF;

    EXECUTE 'SELECT EXISTS (SELECT 1 FROM ' || NOME_TABELA || ' WHERE ' || COLUNA_ID || ' = ''' || VALOR_ID || ''')' INTO REGISTRO_EXISTE;
    
    IF NOT REGISTRO_EXISTE THEN
        RETURN 'ERRO: REGISTRO NÃO ENCONTRADO.';
    END IF;
    
    COMANDO_SQL := 'UPDATE ' || NOME_TABELA || ' SET ' || DADOS_ALTERAR || ' WHERE ' || COLUNA_ID || ' = ''' || VALOR_ID || '''';
    
    BEGIN
        EXECUTE COMANDO_SQL;
        RETURN 'SUCESSO: REGISTRO ATUALIZADO EM ' || NOME_TABELA;
    EXCEPTION WHEN OTHERS THEN
        RETURN 'ERRO AO ALTERAR: VERIFIQUE OS VALORES OU O REGISTRO PODE ESTAR EM USO. DETALHES: ' || SQLERRM;
    END;
END;
$$ LANGUAGE PLPGSQL;

-- ==================================================
-- ==================================================
-- ==================================================
