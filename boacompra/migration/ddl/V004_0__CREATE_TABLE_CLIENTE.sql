/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem do cliente
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_cliente;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_cliente()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_cliente';

    -- 1. Criar a tabela TB_CLIENTE
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_cliente (
              id_cliente                  BIGINT       NOT NULL AUTO_INCREMENT                                        COMMENT ''[DADO_PUBLICO] Chave primaria [PK_CLIENTE]. Identificador do cliente'',
              no_cliente                  VARCHAR(150) NOT NULL                                                       COMMENT ''[DADO_PESSOAL] Nome do cliente'',
              nu_cpf                      VARCHAR(11)  NOT NULL                                                       COMMENT ''[DADO_PESSOAL] Chave unica [UK_CLIENTE_01]. Numero do CPF (Cadastro de Pessoa Fisica) da Receita Federal do Brasil'',
              dt_nascimento               DATE         NOT NULL                                                       COMMENT ''[DADO_PESSOAL] Data de nascimento do cliente'',
              in_ativo                    TINYINT      NOT NULL DEFAULT 1                                             COMMENT ''[DADO_PUBLICO] Indica se o cliente esta ativo. Aceita os valores: 0 (Inativo) e 1 (Ativo)'',
              id_usuario_criacao          BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
              dt_criacao                  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
              id_usuario_atualizacao      BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
              dt_atualizacao              TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
              CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
              CONSTRAINT uk_cliente_01 UNIQUE (nu_cpf),
              CONSTRAINT ck_cliente_01 CHECK (in_ativo IN (0,1))
          ) COMMENT = ''[DADO_PUBLICO] Armazena os clientes''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_cliente criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_cliente já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_CLIENTE_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_cliente_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_cliente_01 ON boacompra_adm.tb_cliente (in_ativo);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_cliente_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_cliente_01 já existe.' AS mensagem;
    END IF;

END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_cliente();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_cliente;
