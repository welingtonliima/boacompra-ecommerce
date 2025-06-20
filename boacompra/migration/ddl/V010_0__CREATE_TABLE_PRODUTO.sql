/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem do produto
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_produto;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_produto()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_produto';

    -- 1. Criar a tabela TB_PRODUTO
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_produto (
             id_produto                   BIGINT         NOT NULL AUTO_INCREMENT                                        COMMENT ''[DADO_PUBLICO] Chave primaria [PK_PRODUTO]. Identificador do produto'',
             id_produto_categoria         SMALLINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_PRODCATE_PRODUTO]. Identificador da categoria do produto'',
             id_produto_unidade_medida    SMALLINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_PRODUNIDMEDI_PRODUTO]. Identificador da unidade de medida do produto'',
             no_produto                   VARCHAR(150)   NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave unica [UK_PRODUTO_01].Nome do produto'',
             ds_produto                   VARCHAR(500)                                                                  COMMENT ''[DADO_PUBLICO] Descricao do produto'',
             vl_produto_unitario          DECIMAL(15,2)  NOT NULL                                                       COMMENT ''[ESTRATEGICO_FINACEIRO] Preco unitario do produto'',
             in_ativo                     TINYINT        NOT NULL DEFAULT 1                                             COMMENT ''[DADO_PUBLICO] Indica se o produto esta ativo. Aceita os valores: 0 (Inativo) e 1 (Ativo)'',
             id_usuario_criacao           BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
             dt_criacao                   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
             id_usuario_atualizacao       BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
             dt_atualizacao               TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
             CONSTRAINT pk_produto PRIMARY KEY (id_produto),
             CONSTRAINT uk_produto_01 UNIQUE (no_produto),
             CONSTRAINT fk_prodcate_produto FOREIGN KEY (id_produto_categoria) REFERENCES boacompra_adm.tb_produto_categoria (id_produto_categoria),
             CONSTRAINT fk_produnidmedi_produto FOREIGN KEY (id_produto_unidade_medida) REFERENCES boacompra_adm.tb_produto_unidade_medida (id_produto_unidade_medida),
             CONSTRAINT ck_produto_01 CHECK (in_ativo IN (0,1))
          ) COMMENT = ''[ESTRATEGICO_FINACEIRO] Armazena os produtos''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_produto criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_produto já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_PRODUTO_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_produto_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_produto_01 ON boacompra_adm.tb_produto (id_produto_categoria);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_produto_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_produto_01 já existe.' AS mensagem;
    END IF;

    -- 4. Criar o indice IDX_PRODUTO_02
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_produto_02';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_produto_02 ON boacompra_adm.tb_produto (id_produto_unidade_medida);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_produto_02 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_produto_02 já existe.' AS mensagem;
    END IF;

    -- 5. Criar o indice IDX_PRODUTO_03
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_produto_03';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_produto_03 ON boacompra_adm.tb_produto (in_ativo);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_produto_03 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_produto_03 já existe.' AS mensagem;
    END IF;
END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_produto();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_produto;
