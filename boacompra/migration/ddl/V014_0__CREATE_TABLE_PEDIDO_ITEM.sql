/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem do item do pedido
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_pedido_item;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_pedido_item()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_pedido_item';

    -- 1. Criar a tabela TB_PEDIDO_ITEM
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_pedido_item (
             id_pedido_item               BIGINT         NOT NULL AUTO_INCREMENT                                        COMMENT ''[DADO_PUBLICO] Chave primaria [PK_PEDIITEM]. Identificador do item do pedido '',
             id_pedido                    BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_PEDIDO_PEDIITEM] e parte da chave unica [UK_PEDIITEM_01]. Identificador do pedido'',
             id_produto                   BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_PRODUTO_PEDIITEM] e parte da chave unica [UK_PEDIITEM_01]. Identificador do produto'',
             qt_item                      INT            NOT NULL                                                       COMMENT ''[ESTRATEGICO_OPERACIONAL] Quantidade de item do produto no pedido'',
             vl_unitario                  DECIMAL(15,2)  NOT NULL                                                       COMMENT ''[ESTRATEGICO_FINACEIRO] Valor unitario do item, sem aplicar o desconto'',
             vl_desconto                  DECIMAL(15,2)  NOT NULL                                                       COMMENT ''[ESTRATEGICO_FINACEIRO] Valor do desconto aplicado ao item do pedido'',
             vl_item_total                DECIMAL(15,2)  NOT NULL                                                       COMMENT ''[ESTRATEGICO_FINACEIRO] Valor total do item, considerando a quantidade e desconto'',
             id_usuario_criacao           BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
             dt_criacao                   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
             id_usuario_atualizacao       BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
             dt_atualizacao               TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
             CONSTRAINT pk_pediitem PRIMARY KEY (id_pedido_item),
             CONSTRAINT uk_pediitem_01 UNIQUE (id_pedido, id_produto),
             CONSTRAINT fk_pedido_pediitem FOREIGN KEY (id_pedido) REFERENCES boacompra_adm.tb_pedido (id_pedido),
             CONSTRAINT fk_produto_pediitem FOREIGN KEY (id_produto) REFERENCES boacompra_adm.tb_produto (id_produto)
          ) COMMENT = ''[ESTRATEGICO_FINACEIRO] Armazena os itens dos pedidos''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_pedido_item criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_pedido_item já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_PEDIITEM_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_pediitem_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_pediitem_01 ON boacompra_adm.tb_pedido_item (id_pedido);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_pediitem_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_pediitem_01 já existe.' AS mensagem;
    END IF;

    -- 3. Criar o indice IDX_PEDIITEM_02
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_pediitem_02';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_pediitem_02 ON boacompra_adm.tb_pedido_item (id_produto);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_pediitem_02 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_pediitem_02 já existe.' AS mensagem;
    END IF;
END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_pedido_item();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_pedido_item;

