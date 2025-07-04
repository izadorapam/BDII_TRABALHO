-- ==================================================
-- ============ TESTES DE VALIDAÇÃO =================
-- ==================================================

-- TESTE 1: VALIDAÇÃO DE E-MAIL DO CLIENTE
-- DEVE FALHAR
INSERT INTO CLIENTE VALUES (300, 'TESTE', 'RUA TESTE', '86999999999', 'emailinvalido');

-- TESTE 2: VALIDAÇÃO DE TELEFONE DO FUNCIONÁRIO
-- DEVE FALHAR
INSERT INTO FUNCIONARIO VALUES (300, 'TESTE', '869999', 'teste@empresa.com', 'TESTE');