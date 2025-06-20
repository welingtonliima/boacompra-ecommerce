/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem do municipio
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_municipio;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_municipio()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_municipio';

    -- 1. Criar a tabela TB_MUNICIPIO
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_municipio (
              id_municipio                INT          NOT NULL AUTO_INCREMENT                                        COMMENT ''[DADO_PUBLICO] Chave primaria [PK_MUNICIPIO]. Identificador do municipio '',
              id_unidade_federativa       TINYINT      NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_UNIDFEDE_MUNICIPIO] e parte da chave unica [UK_MUNICIPIO_02]. Identificador da unidade federativa do municipio'',
              co_municipio_ibge           INT                                                                         COMMENT ''[DADO_PUBLICO] Chave unica [UK_MUNICIPIO_01]. Codigo do IBGE para o municipio'',
              no_municipio                VARCHAR(100) NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Parte da chave unica [UK_MUNICIPIO_02]. Nome do municipio'',
              in_ativo                    TINYINT      NOT NULL DEFAULT 1                                             COMMENT ''[DADO_PUBLICO] Indica se o municipio esta ativo. Aceita os valores: 0 (Inativo) e 1 (Ativo)'',
              id_usuario_criacao          BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
              dt_criacao                  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
              id_usuario_atualizacao      BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
              dt_atualizacao              TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
              CONSTRAINT pk_municipio PRIMARY KEY (id_municipio),
              CONSTRAINT uk_municipio_01 UNIQUE (co_municipio_ibge),
              CONSTRAINT uk_municipio_02 UNIQUE (id_unidade_federativa, no_municipio),
              CONSTRAINT fk_unidfede_municipio FOREIGN KEY (id_unidade_federativa) REFERENCES boacompra_adm.tb_unidade_federativa (id_unidade_federativa),
              CONSTRAINT ck_municipio_01 CHECK (in_ativo IN (0,1))
          ) COMMENT = ''[DADO_PUBLICO] Armazena os municipios do Brasil''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_municipio criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_municipio já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_MUNICIPIO_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_municipio_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_municipio_01 ON boacompra_adm.tb_municipio (id_unidade_federativa);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_municipio_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_municipio_01 já existe.' AS mensagem;
    END IF;

    -- 3. Criar o indice IDX_MUNICIPIO_02
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_municipio_02';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_municipio_02 ON boacompra_adm.tb_municipio (in_ativo);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_municipio_02 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_municipio_02 já existe.' AS mensagem;
    END IF;
END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_municipio();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_municipio;