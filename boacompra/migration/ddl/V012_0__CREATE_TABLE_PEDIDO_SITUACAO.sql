/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem da situação do pedido
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_pedido_situacao;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_pedido_situacao()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_pedido_situacao';

    -- 1. Criar a tabela TB_PRODUTO
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_pedido_situacao (
             co_pedido_situacao           TINYINT        NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave primaria [PK_PEDISITU].  Codigo da situacao do pedido'',
             no_pedido_situacao           VARCHAR(50)    NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave unica [UK_PEDISITU_01].Nome da situacao do pedido'',
             ds_pedido_situacao           VARCHAR(150)                                                                  COMMENT ''[DADO_PUBLICO] Descricao da situacao do pedido'',
             in_ativo                     TINYINT        NOT NULL DEFAULT 1                                             COMMENT ''[DADO_PUBLICO] Indica se a situacao do pedido esta ativa. Aceita os valores: 0 (Inativa) e 1 (Ativa)'',
             id_usuario_criacao           BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
             dt_criacao                   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
             id_usuario_atualizacao       BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
             dt_atualizacao               TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
             CONSTRAINT PK_PEDISITU PRIMARY KEY (co_pedido_situacao),
             CONSTRAINT UK_PEDISITU_01 UNIQUE (no_pedido_situacao)
          ) COMMENT = ''[DADO_PUBLICO] Armazena as situacoes dos pedidos''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_pedido_situacao criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_pedido_situacao já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_PEDISITU_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_pedisitu_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_pedisitu_01 ON boacompra_adm.tb_pedido_situacao (in_ativo);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_pedisitu_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_pedisitu_01 já existe.' AS mensagem;
    END IF;
END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_pedido_situacao();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_pedido_situacao;
