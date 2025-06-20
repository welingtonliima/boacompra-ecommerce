/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem da unidade federativa
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_unidade_federativa;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_unidade_federativa()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_unidade_federativa';

    -- 1. Criar a tabela TB_UNIDADE_FEDERATIVA
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_unidade_federativa (
              id_unidade_federativa       TINYINT      NOT NULL AUTO_INCREMENT                                        COMMENT ''[DADO_PUBLICO] Chave primaria [PK_UNIDFEDE]. Identificador da Unidade Federativa'',
              co_unidade_federativa_ibge  TINYINT                                                                     COMMENT ''[DADO_PUBLICO] Chave unica [UK_UNIDFEDE_01]. Codigo do IBGE para a unidade federativa'',
              no_unidade_federativa       VARCHAR(100) NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave unica [UK_UNIDFEDE_02]. Nome da unidade federativa'',
              sg_unidade_federativa       CHAR(2)      NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave unica [UK_UNIDFEDE_03]. Sigla da unidade federativa'',
              in_ativo                    TINYINT      NOT NULL DEFAULT 1                                             COMMENT ''[DADO_PUBLICO] Indica se a unidade federativa esta ativa. Aceita os valores: 0 (Inativa) e 1 (Ativa)'',
              id_usuario_criacao          BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
              dt_criacao                  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
              id_usuario_atualizacao      BIGINT NOT   NULL                                                           COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
              dt_atualizacao              TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
              CONSTRAINT pk_unidfede PRIMARY KEY (id_unidade_federativa),
              CONSTRAINT uk_unidfede_01 UNIQUE (co_unidade_federativa_ibge),
              CONSTRAINT uk_unidfede_02 UNIQUE (no_unidade_federativa),
              CONSTRAINT uk_unidfede_03 UNIQUE (sg_unidade_federativa),
              CONSTRAINT ck_unidfede_01 CHECK (in_ativo IN (0,1))
          ) COMMENT = ''[DADO_PUBLICO] Armazena as Unidades Federativas do Brasil''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_unidade_federativa criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_unidade_federativa já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_UNIDFEDE_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_unidfede_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_unidfede_01 ON boacompra_adm.tb_unidade_federativa (in_ativo);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_unidfede_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_unidfede_01 já existe.' AS mensagem;
    END IF;

END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_unidade_federativa();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_unidade_federativa;
