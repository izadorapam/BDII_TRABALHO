-- ==================================================
--   ============= FUNÇÕES DE CADASTRO ===============
-- ==================================================

CREATE OR REPLACE FUNCTION CADASTRAR_CLIENTE(
    P_ID INT,
    P_NOME VARCHAR,
    P_ENDERECO VARCHAR,
    P_TELEFONE VARCHAR,
    P_EMAIL VARCHAR
) RETURNS TEXT AS $$
DECLARE
    V_RESULT TEXT;
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM CLIENTE WHERE ID_CLIENTE = P_ID) THEN
            RETURN 'ERRO: ID DE CLIENTE JÁ EXISTE.';
        END IF;
        
        IF P_EMAIL NOT LIKE '%@%.%' THEN
            RETURN 'ERRO: FORMATO DE EMAIL INVÁLIDO.';
        END IF;
        
        INSERT INTO CLIENTE VALUES (P_ID, P_NOME, P_ENDERECO, P_TELEFONE, P_EMAIL);
        
        RETURN 'CLIENTE CADASTRADO COM SUCESSO. ID: ' || P_ID;
        
    EXCEPTION 
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA CADASTRAR CLIENTES.';
        WHEN UNIQUE_VIOLATION THEN
            RETURN 'ERRO: JÁ EXISTE UM CLIENTE COM ESTE ID OU INFORMAÇÕES ÚNICAS.';
        WHEN NOT_NULL_VIOLATION THEN
            RETURN 'ERRO: TODOS OS CAMPOS OBRIGATÓRIOS DEVEM SER PREENCHIDOS.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO AO CADASTRAR CLIENTE: %', SQLERRM;
            RETURN 'ERRO: NÃO FOI POSSÍVEL COMPLETAR O CADASTRO.';
    END;
END;
$$ LANGUAGE PLPGSQL;

-- --------------------------------------------------
CREATE OR REPLACE FUNCTION INSERIR_PEDIDO(
    P_ID_PEDIDO INT,
    P_TOTAL DECIMAL DEFAULT 0
) RETURNS TEXT AS $$
DECLARE
    V_EXISTE BOOLEAN;
BEGIN
    -- Verifica se já existe um pedido com esse ID
    SELECT EXISTS (SELECT 1 FROM PEDIDO WHERE ID_PEDIDO = P_ID_PEDIDO) INTO V_EXISTE;

    IF V_EXISTE THEN
        RETURN 'ERRO: PEDIDO COM ID ' || P_ID_PEDIDO || ' JÁ EXISTE.';
    END IF;

    -- Inserção
    INSERT INTO PEDIDO(ID_PEDIDO, TOTAL) VALUES (P_ID_PEDIDO, P_TOTAL);

    RETURN 'SUCESSO: PEDIDO INSERIDO COM ID ' || P_ID_PEDIDO;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERRO AO INSERIR PEDIDO: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION CADASTRAR_FUNCIONARIO(
    P_ID INT,
    P_NOME VARCHAR,
    P_TELEFONE VARCHAR,
    P_EMAIL VARCHAR,
    P_CARGO VARCHAR
) RETURNS TEXT AS $$
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM FUNCIONARIO WHERE ID_FUNCIONARIO = P_ID) THEN
            RETURN 'ERRO: ID ' || P_ID || ' JÁ ESTÁ CADASTRADO PARA OUTRO FUNCIONÁRIO';
        END IF;
        
        IF P_EMAIL NOT LIKE '%@%.%' THEN
            RETURN 'ERRO: FORMATO DE E-MAIL INVÁLIDO';
        END IF;
        
        IF P_TELEFONE !~ '^[0-9]{10,11}$' THEN
            RETURN 'ERRO: TELEFONE DEVE CONTER 10 OU 11 DÍGITOS NUMÉRICOS';
        END IF;
        
        INSERT INTO FUNCIONARIO VALUES (P_ID, P_NOME, P_TELEFONE, P_EMAIL, P_CARGO);
        
        RETURN 'SUCESSO: FUNCIONÁRIO ' || P_NOME || ' CADASTRADO COM ID ' || P_ID;
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA CADASTRAR FUNCIONÁRIOS.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO AO CADASTRAR FUNCIONÁRIO (ID: %): %', P_ID, SQLERRM;
            RETURN 'ERRO: FALHA AO CADASTRAR FUNCIONÁRIO.';
    END;
END;
$$ LANGUAGE PLPGSQL;
-- --------------------------------------------------

CREATE OR REPLACE FUNCTION CADASTRAR_FORNECEDOR(
    P_ID INT,
    P_NOME VARCHAR,
    P_TELEFONE VARCHAR,
    P_EMAIL VARCHAR
) RETURNS TEXT AS $$
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM FORNECEDOR WHERE ID_FORNECEDOR = P_ID) THEN
            RETURN 'ERRO: FORNECEDOR COM ESTE ID JÁ EXISTE.';
        END IF;
        
        IF P_EMAIL NOT LIKE '%@%.%' THEN
            RETURN 'ERRO: FORMATO DE E-MAIL INVÁLIDO.';
        END IF;
        
        INSERT INTO FORNECEDOR VALUES (P_ID, P_NOME, P_TELEFONE, P_EMAIL);
        
        RETURN 'SUCESSO: FORNECEDOR ' || P_NOME || ' CADASTRADO COM ID ' || P_ID;
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA CADASTRAR FORNECEDORES.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO AO CADASTRAR FORNECEDOR (ID: %): %', P_ID, SQLERRM;
            RETURN 'ERRO: FALHA AO CADASTRAR FORNECEDOR.';
    END;
END;
$$ LANGUAGE PLPGSQL;
-- --------------------------------------------------

CREATE OR REPLACE FUNCTION CADASTRAR_PRODUTO(
    P_ID INT,
    P_ESTOQUE INT,
    P_NOME VARCHAR,
    P_PRECO DECIMAL,
    P_TIPO VARCHAR,
    P_COMPOE INT
) RETURNS TEXT AS $$
BEGIN
    BEGIN
        IF EXISTS (SELECT 1 FROM PRODUTO WHERE ID_PRODUTO = P_ID) THEN
            RETURN 'ERRO: PRODUTO COM ID ' || P_ID || ' JÁ EXISTE.';
        END IF;
        
        IF P_COMPOE IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PRODUTO WHERE ID_PRODUTO = P_COMPOE) THEN
            RETURN 'ERRO: PRODUTO COMPONENTE ' || P_COMPOE || ' NÃO ENCONTRADO.';
        END IF;
        
        INSERT INTO PRODUTO VALUES (P_ID, P_ESTOQUE, P_NOME, P_PRECO, P_TIPO, P_COMPOE);
        
        RETURN 'PRODUTO CADASTRADO COM SUCESSO. ID: ' || P_ID;
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA CADASTRAR PRODUTOS.';
        WHEN CHECK_VIOLATION THEN
            RETURN 'ERRO: VALORES INVÁLIDOS (ESTOQUE NEGATIVO, PREÇO INVÁLIDO, ETC).';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO AO CADASTRAR PRODUTO: %', SQLERRM;
            RETURN 'ERRO: FALHA NO CADASTRO DO PRODUTO.';
    END;
END;
$$ LANGUAGE PLPGSQL;
---------------------------------------------------------
CREATE OR REPLACE FUNCTION CADASTRAR_COMPOSICAO(
    P_ID_PROD_COMP1 INT,
    P_ID_PROD_COMP2 INT,
    P_QUANTIDADE INT,
    P_PERDA DECIMAL DEFAULT 0,
    P_TEMPO_MONTAGEM INT DEFAULT 15
) RETURNS TEXT AS $$
BEGIN
    BEGIN
        -- Verificar se produtos existem
        IF NOT EXISTS (SELECT 1 FROM PRODUTO WHERE ID_PRODUTO = P_ID_PROD_COMP1 AND ATIVO = TRUE) THEN
            RETURN 'ERRO: PRODUTO PRINCIPAL NÃO ENCONTRADO OU INATIVO.';
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM PRODUTO WHERE ID_PRODUTO = P_ID_PROD_COMP2 AND ATIVO = TRUE) THEN
            RETURN 'ERRO: PRODUTO COMPONENTE NÃO ENCONTRADO OU INATIVO.';
        END IF;
        
        -- Verificar se já existe a composição
        IF EXISTS (
            SELECT 1 FROM COMPOSICAO_PRONTA 
            WHERE ID_PROD_COMP1 = P_ID_PROD_COMP1 
            AND ID_PROD_COMP2 = P_ID_PROD_COMP2
            AND ATIVO = TRUE
        ) THEN
            RETURN 'ERRO: ESTA COMPOSIÇÃO JÁ EXISTE.';
        END IF;
        
        -- Cadastrar a composição
        INSERT INTO COMPOSICAO_PRONTA (
            ID_PROD_COMP1, 
            ID_PROD_COMP2, 
            QUANT, 
            PERDA, 
            TEMPO_MONTAGEM
        ) VALUES (
            P_ID_PROD_COMP1,
            P_ID_PROD_COMP2,
            P_QUANTIDADE,
            P_PERDA,
            P_TEMPO_MONTAGEM
        );
        
        RETURN 'SUCESSO: COMPOSIÇÃO CADASTRADA.';
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'ERRO: FALHA AO CADASTRAR COMPOSIÇÃO. ' || SQLERRM;
    END;
END;
$$ LANGUAGE PLPGSQL;
-- ==================================================
--   ========== FUNÇÕES DE ATUALIZAÇÃO ================
-- ==================================================

CREATE OR REPLACE FUNCTION ATUALIZAR_ESTOQUE(
    P_ID INT,
    P_QUANTIDADE INT
) RETURNS TEXT AS $$
BEGIN
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM PRODUTO WHERE ID_PRODUTO = P_ID) THEN
            RETURN 'ERRO: PRODUTO NÃO ENCONTRADO.';
        END IF;
        
        IF P_QUANTIDADE < 0 THEN
            RETURN 'ERRO: QUANTIDADE NÃO PODE SER NEGATIVA.';
        END IF;
        
        UPDATE PRODUTO SET ESTOQUE = P_QUANTIDADE WHERE ID_PRODUTO = P_ID;
        
        RETURN 'ESTOQUE ATUALIZADO COM SUCESSO PARA ' || P_QUANTIDADE || ' UNIDADES.';
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA ATUALIZAR ESTOQUE.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO AO ATUALIZAR ESTOQUE (PRODUTO: %): %', P_ID, SQLERRM;
            RETURN 'ERRO: FALHA NA ATUALIZAÇÃO DO ESTOQUE.';
    END;
END;
$$ LANGUAGE PLPGSQL;
-- --------------------------------------------------

CREATE OR REPLACE FUNCTION ATUALIZAR_ESTOQUE_COMPRA() RETURNS TRIGGER AS $$
BEGIN
    UPDATE PRODUTO SET ESTOQUE = ESTOQUE + NEW.QUANT WHERE ID_PRODUTO = NEW.ID_PRODUTO;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TRG_ESTOQUE_COMPRA
AFTER INSERT ON ITEM_COMPRA
FOR EACH ROW
EXECUTE FUNCTION ATUALIZAR_ESTOQUE_COMPRA();

-- --------------------------------------------------

CREATE OR REPLACE FUNCTION ATUALIZAR_ESTOQUE_PEDIDO() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT ATIVO FROM PEDIDO WHERE ID_PEDIDO = NEW.ID_PEDIDO) = FALSE THEN
        RAISE EXCEPTION 'PEDIDO INATIVO: %', NEW.ID_PEDIDO;
    END IF;
    
    IF (SELECT ATIVO FROM PRODUTO WHERE ID_PRODUTO = NEW.ID_PRODUTO) = FALSE THEN
        RAISE EXCEPTION 'PRODUTO INATIVO: %', NEW.ID_PRODUTO;
    END IF;
    
    IF (SELECT ESTOQUE FROM PRODUTO WHERE ID_PRODUTO = NEW.ID_PRODUTO) < NEW.QUANT THEN
        RAISE EXCEPTION 'ESTOQUE INSUFICIENTE PARA O PRODUTO %', NEW.ID_PRODUTO;
    END IF;
    
    UPDATE PRODUTO SET ESTOQUE = ESTOQUE - NEW.QUANT WHERE ID_PRODUTO = NEW.ID_PRODUTO;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER TRG_ESTOQUE_PEDIDO
BEFORE INSERT ON ITEM_PEDIDO
FOR EACH ROW
EXECUTE FUNCTION ATUALIZAR_ESTOQUE_PEDIDO();

-- ==================================================
--   =========== FUNÇÕES DE REMOÇÃO ===================
-- ==================================================

CREATE OR REPLACE FUNCTION REMOVER_CLIENTE(P_ID INT) RETURNS TEXT AS $$
BEGIN
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM CLIENTE WHERE ID_CLIENTE = P_ID) THEN
            RETURN 'ERRO: CLIENTE NÃO ENCONTRADO.';
        END IF;
        
        IF EXISTS (SELECT 1 FROM PEDIDO WHERE ID_CLIENTE = P_ID AND ATIVO = TRUE) THEN
            RETURN 'ERRO: CLIENTE POSSUI PEDIDOS ATIVOS ASSOCIADOS.';
        END IF;
        
        UPDATE CLIENTE SET ATIVO = FALSE WHERE ID_CLIENTE = P_ID;
        
        RETURN 'SUCESSO: CLIENTE MARCADO COMO INATIVO. ID: ' || P_ID;
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA REMOVER CLIENTES.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO AO REMOVER CLIENTE (ID: %): %', P_ID, SQLERRM;
            RETURN 'ERRO: FALHA AO REMOVER CLIENTE.';
    END;
END;
$$ LANGUAGE PLPGSQL;

-- --------------------------------------------------

CREATE OR REPLACE FUNCTION REMOVER_PRODUTO(P_ID INT) RETURNS TEXT AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PRODUTO WHERE ID_PRODUTO = P_ID) THEN
        RETURN 'ERRO: PRODUTO NÃO ENCONTRADO.';
    END IF;
    
    IF EXISTS (SELECT 1 FROM ITEM_PEDIDO IP JOIN PEDIDO P ON IP.ID_PEDIDO = P.ID_PEDIDO
               WHERE IP.ID_PRODUTO = P_ID AND P.ATIVO = TRUE) THEN
        RETURN 'ERRO: PRODUTO ESTÁ EM PEDIDOS ATIVOS.';
    END IF;
    
    IF EXISTS (SELECT 1 FROM COMPOSICAO_PRONTA
               WHERE (ID_PROD_COMP1 = P_ID OR ID_PROD_COMP2 = P_ID) AND ATIVO = TRUE) THEN
        RETURN 'ERRO: PRODUTO ESTÁ EM COMPOSIÇÕES ATIVAS.';
    END IF;
    
    UPDATE PRODUTO SET ATIVO = FALSE WHERE ID_PRODUTO = P_ID;
    
    RETURN 'PRODUTO MARCADO COMO INATIVO COM SUCESSO. ID: ' || P_ID;
EXCEPTION WHEN OTHERS THEN
    RETURN 'ERRO AO REMOVER PRODUTO: ' || SQLERRM;
END;
$$ LANGUAGE PLPGSQL;
-------------------------------------------------------------
-- Função específica para remover pedido
CREATE OR REPLACE FUNCTION REMOVER_PEDIDO(P_ID_PEDIDO INT) RETURNS TEXT AS $$
BEGIN
    -- Primeiro desativar itens do pedido
    UPDATE ITEM_PEDIDO SET ATIVO = FALSE WHERE ID_PEDIDO = P_ID_PEDIDO;
    
    -- Depois desativar o pedido
    UPDATE PEDIDO SET ATIVO = FALSE WHERE ID_PEDIDO = P_ID_PEDIDO;
    
    RETURN 'PEDIDOS E ITENS MARCADOS COMO INATIVOS';
EXCEPTION WHEN OTHERS THEN
    RETURN 'ERRO: ' || SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

-- Função específica para remover compra
CREATE OR REPLACE FUNCTION REMOVER_COMPRA(P_ID_COMPRA INT) RETURNS TEXT AS $$
BEGIN
    -- Primeiro desativar itens da compra
    UPDATE ITEM_COMPRA SET ATIVO = FALSE WHERE ID_COMPRA = P_ID_COMPRA;
    
    -- Depois desativar a compra
    UPDATE COMPRA SET ATIVO = FALSE WHERE ID_COMPRA = P_ID_COMPRA;
    
    RETURN 'COMPRA E ITENS MARCADOS COMO INATIVOS';
EXCEPTION WHEN OTHERS THEN
    RETURN 'ERRO: ' || SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

----------------------------------------------
-- ==================================================
--   ========== FUNÇÕES DE REGISTRO ===================
-- ==================================================

CREATE OR REPLACE FUNCTION REGISTRAR_PEDIDO(
    P_ID_PEDIDO INT,
    P_ID_CLIENTE INT,
    P_TELEFONE VARCHAR,
    P_ID_FUNCIONARIO INT,
    P_ITEMS JSONB  -- Array de objetos {id_produto, quantidade}
) RETURNS TEXT AS $$
DECLARE
    V_CLIENTE_EXISTE BOOLEAN;
    V_FUNCIONARIO_EXISTE BOOLEAN;
    V_PRODUTO_EXISTE BOOLEAN;
    V_TOTAL_PEDIDO DECIMAL(10,2) := 0;
    V_ITEM JSONB;
    V_QUANTIDADE INT;
    V_PRECO DECIMAL(10,2);
    V_ESTOQUE_SUFICIENTE BOOLEAN;
    V_PRODUTO_COMPOSTO BOOLEAN;
    V_MENSAGEM TEXT;
BEGIN
    BEGIN
        -- Validações básicas
        SELECT EXISTS (SELECT 1 FROM CLIENTE WHERE ID_CLIENTE = P_ID_CLIENTE) INTO V_CLIENTE_EXISTE;
        IF NOT V_CLIENTE_EXISTE THEN
            RETURN 'ERRO: CLIENTE NÃO ENCONTRADO.';
        END IF;

        SELECT EXISTS (SELECT 1 FROM FUNCIONARIO WHERE ID_FUNCIONARIO = P_ID_FUNCIONARIO) INTO V_FUNCIONARIO_EXISTE;
        IF NOT V_FUNCIONARIO_EXISTE THEN
            RETURN 'ERRO: FUNCIONÁRIO NÃO ENCONTRADO.';
        END IF;

        -- Verificar cada item do pedido
        FOR V_ITEM IN SELECT * FROM JSONB_ARRAY_ELEMENTS(P_ITEMS)
        LOOP
            -- Verificar se produto existe
            SELECT EXISTS (
                SELECT 1 FROM PRODUTO 
                WHERE ID_PRODUTO = (V_ITEM->>'id_produto')::INT AND ATIVO = TRUE
            ) INTO V_PRODUTO_EXISTE;
            
            IF NOT V_PRODUTO_EXISTE THEN
                RETURN 'ERRO: PRODUTO ' || (V_ITEM->>'id_produto') || ' NÃO ENCONTRADO OU INATIVO.';
            END IF;
            
            -- Verificar se é produto composto
            SELECT EXISTS (
                SELECT 1 FROM COMPOSICAO_PRONTA 
                WHERE ID_PROD_COMP1 = (V_ITEM->>'id_produto')::INT AND ATIVO = TRUE
            ) INTO V_PRODUTO_COMPOSTO;
            
            -- Verificar estoque (considerando composições)
            IF V_PRODUTO_COMPOSTO THEN
                SELECT VERIFICAR_ESTOQUE_COMPOSICAO_RECURSIVO(
                    (V_ITEM->>'id_produto')::INT,
                    (V_ITEM->>'quantidade')::INT
                ) INTO V_ESTOQUE_SUFICIENTE;
                
                IF NOT V_ESTOQUE_SUFICIENTE THEN
                    -- Tentar montar o produto composto
                    SELECT MONTAR_PRODUTO_COMPOSTO(
                        (V_ITEM->>'id_produto')::INT,
                        (V_ITEM->>'quantidade')::INT
                    ) INTO V_MENSAGEM;
                    
                    IF V_MENSAGEM NOT LIKE 'SUCESSO%' THEN
                        RETURN 'ERRO: ESTOQUE INSUFICIENTE PARA O PRODUTO COMPOSTO ' || 
                               (V_ITEM->>'id_produto') || '. ' || V_MENSAGEM;
                    END IF;
                END IF;
            ELSE
                -- Produto simples - verificar estoque diretamente
                SELECT ESTOQUE >= (V_ITEM->>'quantidade')::INT
                FROM PRODUTO
                WHERE ID_PRODUTO = (V_ITEM->>'id_produto')::INT
                INTO V_ESTOQUE_SUFICIENTE;
                
                IF NOT V_ESTOQUE_SUFICIENTE THEN
                    RETURN 'ERRO: ESTOQUE INSUFICIENTE PARA O PRODUTO ' || (V_ITEM->>'id_produto');
                END IF;
            END IF;
            
            -- Obter preço do produto
            SELECT PRECO INTO V_PRECO
            FROM PRODUTO
            WHERE ID_PRODUTO = (V_ITEM->>'id_produto')::INT;
            
            -- Calcular total parcial
            V_TOTAL_PEDIDO := V_TOTAL_PEDIDO + (V_PRECO * (V_ITEM->>'quantidade')::INT);
        END LOOP;

        -- Registrar o pedido
        INSERT INTO PEDIDO (ID_PEDIDO, ID_CLIENTE, TELEFONE, TOTAL, ID_FUNCIONARIO)
        VALUES (P_ID_PEDIDO, P_ID_CLIENTE, P_TELEFONE, V_TOTAL_PEDIDO, P_ID_FUNCIONARIO);
        
        -- Registrar os itens do pedido
        FOR V_ITEM IN SELECT * FROM JSONB_ARRAY_ELEMENTS(P_ITEMS)
        LOOP
            INSERT INTO ITEM_PEDIDO (ID_PEDIDO, ID_PRODUTO, QUANT)
            VALUES (
                P_ID_PEDIDO,
                (V_ITEM->>'id_produto')::INT,
                (V_ITEM->>'quantidade')::INT
            );
            
            -- Atualizar estoque (o trigger TRG_ESTOQUE_PEDIDO já faz isso)
        END LOOP;
        
        RETURN 'PEDIDO REGISTRADO COM SUCESSO. TOTAL: R$ ' || V_TOTAL_PEDIDO;
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA REGISTRAR PEDIDOS.';
        WHEN UNIQUE_VIOLATION THEN
            RETURN 'ERRO: JÁ EXISTE UM PEDIDO COM ESTE ID.';
        WHEN FOREIGN_KEY_VIOLATION THEN
            RETURN 'ERRO: DADOS REFERENCIADOS NÃO ENCONTRADOS.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO AO REGISTRAR PEDIDO (ID: %): %', P_ID_PEDIDO, SQLERRM;
            RETURN 'ERRO: FALHA AO REGISTRAR O PEDIDO.';
    END;
END;
$$ LANGUAGE PLPGSQL;

----EX DE USO
SELECT REGISTRAR_PEDIDO(
    1001,                   -- ID_PEDIDO
    1,                      -- ID_CLIENTE
    '86999990001',          -- TELEFONE
    1,                      -- ID_FUNCIONARIO
    '[                      -- ITEMS (JSON)
        {"id_produto": 3, "quantidade": 2},  -- Arranjo de rosas (composto)
        {"id_produto": 8, "quantidade": 1}   -- Cartão especial (simples)
    ]'::JSONB
);
-- --------------------------------------------------

CREATE OR REPLACE FUNCTION REGISTRAR_COMPRA(
    P_ID_COMPRA INT,
    P_ID_FORNECEDOR INT,
    P_DATA DATE,
    P_ID_FUNCIONARIO INT,
    P_ID_PRODUTO1 INT,
    P_QUANT1 INT,
    P_VALOR1 DECIMAL,
    P_ID_PRODUTO2 INT DEFAULT NULL,
    P_QUANT2 INT DEFAULT NULL,
    P_VALOR2 DECIMAL DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    V_FORNECEDOR_EXISTE BOOLEAN;
    V_FUNCIONARIO_EXISTE BOOLEAN;
    V_PRODUTO_EXISTE BOOLEAN;
BEGIN
    BEGIN
        -- VALIDAÇÕES
        SELECT EXISTS (SELECT 1 FROM FORNECEDOR WHERE ID_FORNECEDOR = P_ID_FORNECEDOR) INTO V_FORNECEDOR_EXISTE;
        IF NOT V_FORNECEDOR_EXISTE THEN
            RETURN 'ERRO: FORNECEDOR NÃO ENCONTRADO.';
        END IF;

        SELECT EXISTS (SELECT 1 FROM FUNCIONARIO WHERE ID_FUNCIONARIO = P_ID_FUNCIONARIO) INTO V_FUNCIONARIO_EXISTE;
        IF NOT V_FUNCIONARIO_EXISTE THEN
            RETURN 'ERRO: FUNCIONÁRIO NÃO ENCONTRADO.';
        END IF;

        SELECT EXISTS (SELECT 1 FROM PRODUTO WHERE ID_PRODUTO = P_ID_PRODUTO1) INTO V_PRODUTO_EXISTE;
        IF NOT V_PRODUTO_EXISTE THEN
            RETURN 'ERRO: PRODUTO PRINCIPAL NÃO ENCONTRADO.';
        END IF;

        IF P_ID_PRODUTO2 IS NOT NULL THEN
            SELECT EXISTS (SELECT 1 FROM PRODUTO WHERE ID_PRODUTO = P_ID_PRODUTO2) INTO V_PRODUTO_EXISTE;
            IF NOT V_PRODUTO_EXISTE THEN
                RETURN 'ERRO: PRODUTO ADICIONAL NÃO ENCONTRADO.';
            END IF;
        END IF;

        -- OPERAÇÕES
        INSERT INTO COMPRA VALUES (P_ID_COMPRA, P_ID_FORNECEDOR, P_DATA, 0, P_ID_FUNCIONARIO);

        INSERT INTO ITEM_COMPRA(ID_COMPRA, ID_PRODUTO, QUANT, VALOR_UNITARIO)
        VALUES (P_ID_COMPRA, P_ID_PRODUTO1, P_QUANT1, P_VALOR1);

        IF P_ID_PRODUTO2 IS NOT NULL THEN
            INSERT INTO ITEM_COMPRA(ID_COMPRA, ID_PRODUTO, QUANT, VALOR_UNITARIO)
            VALUES (P_ID_COMPRA, P_ID_PRODUTO2, P_QUANT2, P_VALOR2);
        END IF;

        RETURN 'SUCESSO: COMPRA REGISTRADA COM ID ' || P_ID_COMPRA;
        
    EXCEPTION
        WHEN INSUFFICIENT_PRIVILEGE THEN
            RETURN 'ERRO: SEU PERFIL NÃO TEM PERMISSÃO PARA REGISTRAR COMPRAS.';
        WHEN OTHERS THEN
            RAISE LOG 'ERRO AO REGISTRAR COMPRA (ID: %): %', P_ID_COMPRA, SQLERRM;
            RETURN 'ERRO: FALHA AO REGISTRAR COMPRA.';
    END;
END;
$$ LANGUAGE PLPGSQL;
-- ==================================================
--   ==================================================
-- ==================================================
