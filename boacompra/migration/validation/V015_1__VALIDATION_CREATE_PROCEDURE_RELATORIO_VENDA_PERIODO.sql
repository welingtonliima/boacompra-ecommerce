/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Validacao da criação da procedure do relatório venda no periodo
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;


-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_validation_relatorio_venda_periodo;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_validation_relatorio_venda_periodo()
BEGIN
    DECLARE v_erros INT;

    SELECT COUNT(*) INTO v_erros
    FROM (
        SELECT 'CARD-001' AS request,
               'VSQL_101' AS script,
               'CREATE PROCEDURE [BOACOMPRA_ADM.PRC_RELATORIO_VENDA_PERIODO]' AS operation,
               CASE
                   WHEN (SELECT COUNT(*)
                         FROM information_schema.routines
                         WHERE routine_schema = 'boacompra_adm'
                           AND routine_name   = 'prc_relatorio_venda_periodo'
                           AND routine_type   = 'PROCEDURE') > 0 THEN 'OK'
                   ELSE 'ERROR'
               END AS result,
               NOW() AS dat_validation,
               NULL AS comment
    ) AS validation
    WHERE result = 'ERROR';

    IF v_erros > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro de validação';
    END IF;
END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_validation_relatorio_venda_periodo();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_validation_relatorio_venda_periodo;
