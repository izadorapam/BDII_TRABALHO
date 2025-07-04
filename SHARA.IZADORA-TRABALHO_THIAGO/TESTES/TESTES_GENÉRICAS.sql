-- ==================================================
-- ====== TESTES DAS FUNÇÕES GENÉRICAS ==============
-- ==================================================

-- TESTE 1: CADASTRAR DADO GENÉRICO
SELECT CADASTRAR_DADO('CLIENTE', 'ID_CLIENTE, NOME, ENDERECO, TELEFONE, EMAIL', 
                     '200, ''TESTE GENÉRICO'', ''RUA TESTE'', ''86999999999'', ''teste@email.com''');

-- TESTE 2: REMOVER DADO GENÉRICO
SELECT REMOVER_DADO('CLIENTE', 'ID_CLIENTE', '200');

-- TESTE 3: ALTERAR DADO GENÉRICO
SELECT ALTERAR_DADO('CLIENTE', 'ID_CLIENTE', '1', 'NOME = ''NOVO NOME''');