/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Validacao da criação da unidade federativa
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_validation_unidade_federativa;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_validation_unidade_federativa()
BEGIN
    DECLARE v_erros INT;

    SELECT COUNT(*) INTO v_erros
    FROM (
        SELECT 'CARD-001' AS request,
               'VSQL_101' AS script,
               'CREATE TABLE [BOACOMPRA_ADM.TB_UNIDADE_FEDERATIVA]' AS operation,
               CASE
                   WHEN (SELECT COUNT(*)
                         FROM information_schema.tables
                         WHERE table_schema = 'boacompra_adm'
                           AND table_name = 'tb_unidade_federativa') > 0 THEN 'OK'
                   ELSE 'ERROR'
               END AS result,
               NOW() AS dat_validation,
               (SELECT table_comment
                FROM information_schema.tables
                WHERE table_schema = 'boacompra_adm'
                  AND table_name = 'tb_unidade_federativa'
                LIMIT 1) AS comment
        UNION
        SELECT 'CARD-001' AS request,
               'VSQL_102' AS script,
               'CREATE INDEX [BOACOMPRA_ADM.IDX_UNIDFEDE_01] FOR [BOACOMPRA_ADM.TB_UNIDADE_FEDERATIVA]' AS operation,
               CASE
                   WHEN (SELECT COUNT(*)
                         FROM information_schema.statistics
                         WHERE table_schema = 'boacompra_adm'
                           AND table_name = 'tb_unidade_federativa'
                           AND index_name = 'idx_unidfede_01') > 0 THEN 'OK'
                   ELSE 'ERROR'
               END AS result,
               NOW() AS dat_validation,
               (SELECT GROUP_CONCAT(column_name ORDER BY seq_in_index SEPARATOR ', ')
                FROM information_schema.statistics
                WHERE table_schema = 'boacompra_adm'
                  AND table_name = 'tb_unidade_federativa'
                  AND index_name = 'idx_unidfede_01') AS comment
    ) AS validation
    WHERE result = 'ERROR';

    IF v_erros > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro de validação: tabela ou índice não existe conforme esperado.';
    END IF;

END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_validation_unidade_federativa();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_validation_unidade_federativa;
