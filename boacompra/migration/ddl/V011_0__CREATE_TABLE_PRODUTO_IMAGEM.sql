/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem da imagem do produto
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_produto_imagem;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_produto_imagem()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_produto_imagem';

    -- 1. Criar a tabela TB_PRODUTO
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_produto_imagem (
             id_produto_imagem            BIGINT         NOT NULL AUTO_INCREMENT                                        COMMENT ''[DADO_PUBLICO] Chave primaria [PK_PRODIMAG]. Identificador da imagem do produto'',
             id_produto                   BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_PRODUTO_PRODIMAG] e parte da chave unica [UK_PRODIMAG_01]. Identificador do produto'',
             tx_caminho_imagem            VARCHAR(255)   NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Caminho fisico da imagem do produto'',
             nu_ordem_imagem              TINYINT        NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Parte da chave unica [UK_PRODIMAG_01]. Ordem de exibicao da imagem'',
             id_usuario_criacao           BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
             dt_criacao                   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
             id_usuario_atualizacao       BIGINT         NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
             dt_atualizacao               TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
             CONSTRAINT pk_prodimag PRIMARY KEY (id_produto_imagem),
             CONSTRAINT uk_produto_01 UNIQUE (id_produto, nu_ordem_imagem),
             CONSTRAINT fk_produto_prodimag FOREIGN KEY (id_produto) REFERENCES boacompra_adm.tb_produto (id_produto)
          ) COMMENT = ''[DADO_PUBLICO] Armazena as imagens dos produtos''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_produto_imagem criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_produto_imagem já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_PRODIMAG_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_prodimag_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_prodimag_01 ON boacompra_adm.tb_produto_imagem (id_produto);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_prodimag_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_prodimag_01 já existe.' AS mensagem;
    END IF;
END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_produto_imagem();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_produto_imagem;
