/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Validacao da criação da modelagem da situacao do pedido
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;


-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_validation_pedido_situacao;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_validation_pedido_situacao()
BEGIN
    DECLARE v_erros INT;


    select * from boacompra_adm.tb_pedido_situacao WHERE no_pedido_situacao IN ('PENDENTE','APROVADO','CONCLUIDO','REJEITADO','EM ANDAMENTO');

    SELECT COUNT(*) INTO v_erros
    FROM (
        SELECT 'CARD-001' AS request,
               'VSQL_101' AS script,
               'DML TABLE [BOACOMPRA_ADM.TB_PEDIDO_SITUACAO]' AS operation,
               CASE
                   WHEN (SELECT COUNT(*)
                         FROM boacompra_adm.tb_pedido_situacao
                         WHERE no_pedido_situacao IN ('PENDENTE','APROVADO','CONCLUIDO','REJEITADO','EM ANDAMENTO')) = 5 THEN 'OK'
                   ELSE 'ERROR'
               END AS result,
               NOW() AS dat_validation,
               null AS comment
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
CALL prc_validation_pedido_situacao();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_validation_pedido_situacao;
