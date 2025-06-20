/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Criação da procedure do relatório venda no periodo
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS boacompra_adm.prc_relatorio_venda_periodo;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE boacompra_adm.prc_relatorio_venda_periodo(
    IN pdt_inicio_pedido DATE,
    IN pdt_fim_pedido    DATE,
    IN pno_categoria     VARCHAR(100),
    OUT podc_resultado_relatorio JSON
)
BEGIN
    DECLARE vqt_pedido          BIGINT DEFAULT 0;
    DECLARE vvl_pedido_total    DECIMAL(15, 2) DEFAULT 0.00;
    DECLARE vvl_pedido_media    DECIMAL(15, 2) DEFAULT 0.00;
    DECLARE vdc_produto_vendido JSON DEFAULT JSON_ARRAY();

    SELECT COUNT(1)                                         AS qt_pedido,
           ROUND(IFNULL(SUM(pedido.vl_pedido_total), 0), 2) AS vl_pedido_total,
           ROUND(IFNULL(AVG(pedido.vl_pedido_total), 0), 2) AS vl_pedido_medio
    INTO vqt_pedido, vvl_pedido_total, vvl_pedido_media
    FROM boacompra_adm.tb_pedido pedido
    WHERE 1 = 1
      AND pedido.dt_pedido BETWEEN pdt_inicio_pedido AND pdt_fim_pedido;

    SELECT IFNULL(JSON_ARRAYAGG(
                      JSON_OBJECT(
                          'no_produto', no_produto,
                          'qt_item_vendido', qt_total_item_vendido)),
                  JSON_ARRAY()) AS produtos_vendidos
    INTO vdc_produto_vendido
    FROM (SELECT produto.no_produto               AS no_produto,
                 IFNULL(SUM(pediitem.qt_item), 0) AS qt_total_item_vendido
          FROM boacompra_adm.tb_pedido_item                 pediitem
              INNER JOIN boacompra_adm.tb_pedido            pedido ON pediitem.id_pedido = pedido.id_pedido
              INNER JOIN boacompra_adm.tb_produto           produto ON pediitem.id_produto = produto.id_produto
              INNER JOIN boacompra_adm.tb_produto_categoria prodcate ON produto.id_produto_categoria = prodcate.id_produto_categoria
          WHERE 1 = 1
            AND pedido.dt_pedido BETWEEN pdt_inicio_pedido AND pdt_fim_pedido
            AND prodcate.no_produto_categoria = pno_categoria
          GROUP BY produto.no_produto) AS temp;

    SET podc_resultado_relatorio = JSON_OBJECT(
            'qt_total_pedido', vqt_pedido,
            'vl_total_pedido', vvl_pedido_total,
            'vl_media_pedido', vvl_pedido_media,
            'dc_produto', vdc_produto_vendido);
END;
//
DELIMITER ;


