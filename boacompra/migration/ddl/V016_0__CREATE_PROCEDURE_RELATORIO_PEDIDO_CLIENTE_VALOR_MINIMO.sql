/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Criação da procedure para gerar relatório de pedidos concluídos de clientes acima do mínimo
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS boacompra_adm.prc_relatorio_pedido_cliente_valor_minino;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE boacompra_adm.prc_relatorio_pedido_cliente_valor_minino (
    IN pdt_inicio_pedido      DATE,
    IN pdt_fim_pedido         DATE,
    IN pno_situacao_pedido    VARCHAR(100),
    IN pvl_minino_pedido      DECIMAL(15,0),
    IN pnu_limite             INT,
    IN pnu_pagina             INT,
    OUT podc_resultado_relatorio JSON
)
BEGIN
    DECLARE vnu_offset           INT;
    DECLARE vdc_pedido           JSON DEFAULT JSON_ARRAY();
    DECLARE vdt_inicio           TIMESTAMP;
    DECLARE vdt_fim              TIMESTAMP;
    DECLARE vno_situacao         VARCHAR(100);
    DECLARE vvl_minino_pedido    DECIMAL(15,0);
    DECLARE vnu_limite           INT;
    DECLARE vnu_pagina           INT;
    DECLARE vqt_registro         INT;

    SET vdt_inicio = COALESCE(pdt_inicio_pedido, CURDATE() - INTERVAL 12 MONTH);
    SET vdt_inicio = TIMESTAMP(DATE(vdt_inicio), '00:00:00');

    SET vdt_fim = COALESCE(pdt_fim_pedido, CURDATE());
    SET vdt_fim = TIMESTAMP(DATE(vdt_fim), '23:59:59');

    SET vno_situacao      = IFNULL(pno_situacao_pedido, 'Concluido');
    SET vvl_minino_pedido = IFNULL(pvl_minino_pedido, 1000);
    SET vnu_limite        = IFNULL(pnu_limite, 50);
    SET vnu_pagina        = IFNULL(pnu_pagina, 1);

    SET vnu_offset = (vnu_pagina - 1) * vnu_limite;


    SELECT IFNULL(JSON_ARRAYAGG(
                          JSON_OBJECT(
                                  'no_cliente', no_cliente,
                                  'id_pedido', id_pedido,
                                  'vl_pedido_total', vl_pedido_total,
                                  'dt_pedido', dt_pedido
                          )
                  ), JSON_ARRAY())
    INTO vdc_pedido
    FROM (SELECT cliente.no_cliente                        AS no_cliente,
                 pedido.id_pedido                          AS id_pedido,
                 pedido.vl_pedido_total                    AS vl_pedido_total,
                 DATE_FORMAT(pedido.dt_pedido, '%Y-%m-%d') AS dt_pedido
          FROM boacompra_adm.tb_cliente                   cliente
              INNER JOIN boacompra_adm.tb_pedido          pedido ON cliente.id_cliente = pedido.id_cliente
              INNER JOIN boacompra_adm.tb_pedido_situacao situacao ON pedido.co_pedido_situacao = situacao.co_pedido_situacao
          WHERE 1 = 1
            AND situacao.no_pedido_situacao = vno_situacao
            AND pedido.vl_pedido_total > vvl_minino_pedido
            AND pedido.dt_pedido BETWEEN vdt_inicio AND vdt_fim
          ORDER BY pedido.dt_pedido DESC
          LIMIT vnu_limite OFFSET vnu_offset) tmp;


    SET vqt_registro = JSON_LENGTH(vdc_pedido);

    SET podc_resultado_relatorio = JSON_OBJECT(
        'dt_inicio_relatorio', DATE_FORMAT(vdt_inicio, '%Y-%m-%d %H:%i:%s'),
        'dt_fim_relatorio', DATE_FORMAT(vdt_fim, '%Y-%m-%d %H:%i:%s'),
        'nu_pagina', vnu_pagina,
        'qt_registro', IFNULL(vqt_registro, 0),
        'dc_resultado', vdc_pedido
    );
END;
//
DELIMITER ;
;


