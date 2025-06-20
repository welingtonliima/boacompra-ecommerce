/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Inclusão ou atualização das situações de pedido
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Inclusão ou atualização das situações de pedido
-- +---------------------------------------------------------+--
INSERT INTO boacompra_adm.tb_pedido_situacao (
    co_pedido_situacao,
    no_pedido_situacao,
    ds_pedido_situacao,
    in_ativo,
    id_usuario_criacao,
    id_usuario_atualizacao
)
VALUES
    (1, 'PENDENTE', 'Pendente', 1, 1, 1),
    (2, 'APROVADO', 'Aprovado', 1, 1, 1),
    (3, 'CONCLUIDO', 'Concluido', 1, 1, 1),
    (4, 'REJEITADO', 'Rejeitado', 1, 1, 1),
    (5, 'EM ANDAMENTO', 'Em Andamento', 1, 1, 1)
ON DUPLICATE KEY UPDATE
    no_pedido_situacao = VALUES(no_pedido_situacao),
    ds_pedido_situacao = VALUES(ds_pedido_situacao),
    in_ativo = VALUES(in_ativo),
    id_usuario_atualizacao = VALUES(id_usuario_atualizacao);