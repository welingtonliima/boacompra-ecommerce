/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem do pedido
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_pedido;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_pedido()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_pedido';

    -- 1. Criar a tabela TB_PEDIDO
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_pedido (
             id_pedido                    BIGINT         NOT NULL AUTO_INCREMENT                                        COMMENT ''[DADO_PUBLICO] Chave primaria [PK_PEDIDO]. Identificador do pedido'',
             id_cliente                   BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_CLIENTE_PEDIDO]. Identificador do cliente'',
             co_pedido_situacao           TINYINT        NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_PEDISITU_PEDIDO]. Codigo da situacao do pedido'',
             dt_pedido                    DATE           NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Data do pedido'',
             vl_pedido_total              DECIMAL(15,2)                                                                 COMMENT ''[ESTRATEGICO_FINACEIRO] Valor total do pedido'',
             tx_observacao                VARCHAR(500)                                                                  COMMENT ''[DADO_PUBLICO] Informacao complementar e observacao do pedido'',
             id_usuario_criacao           BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
             dt_criacao                   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
             id_usuario_atualizacao       BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
             dt_atualizacao               TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
             CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
             CONSTRAINT fk_cliente_pedido FOREIGN KEY (id_cliente) REFERENCES boacompra_adm.tb_cliente (id_cliente),
             CONSTRAINT fk_pedisitu_pedido FOREIGN KEY (co_pedido_situacao) REFERENCES boacompra_adm.tb_pedido_situacao (co_pedido_situacao)
          ) COMMENT = ''[ESTRATEGICO_FINACEIRO] Armazena os pedidos''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_pedido criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_pedido já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_PEDIDO_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_pedido_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_pedido_01 ON boacompra_adm.tb_pedido (id_cliente);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_pedido_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_pedido_01 já existe.' AS mensagem;
    END IF;

    -- 3. Criar o indice IDX_PEDIDO_02
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_pedido_02';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_pedido_02 ON boacompra_adm.tb_pedido (co_pedido_situacao);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_pedido_02 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_pedido_02 já existe.' AS mensagem;
    END IF;

    -- 4. Criar o indice IDX_PEDIDO_03
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_pedido_03';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_pedido_03 ON boacompra_adm.tb_pedido (dt_pedido);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_pedido_03 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_pedido_03 já existe.' AS mensagem;
    END IF;
END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_pedido();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_pedido;
