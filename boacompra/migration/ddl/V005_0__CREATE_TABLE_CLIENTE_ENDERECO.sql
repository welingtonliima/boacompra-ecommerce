/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem do endereco do cliente
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_cliente_endereco;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_cliente_endereco()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_cliente_endereco';

    -- 1. Criar a tabela TB_CLIENTE_ENDERECO
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_cliente_endereco (
              id_cliente_endereco         BIGINT       NOT NULL AUTO_INCREMENT                                        COMMENT ''[DADO_PUBLICO] Chave primaria [PK_CLIEENDE]. Identificador do email do cliente'',
              id_cliente                  BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_CLIENTE_CLIEENDE] e chave unica [UK_CLIEENDE_01]. Identificador do cliente'',
              id_municipio                INT          NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_MUNICIPIO_CLIEENDE]. Identificador do municipio do endereco'',
              no_logradouro               VARCHAR(100) NOT NULL                                                       COMMENT ''[DADO_PESSOAL] Logradouro do endereco do cliente'',
              nu_endereco                 VARCHAR(20)  NOT NULL                                                       COMMENT ''[DADO_PESSOAL] Numero do endereco do cliente'',
              ds_complemento              VARCHAR(100)                                                                COMMENT ''[DADO_PESSOAL] Descricao do complemento do endereco do cliente'',
              no_bairro                   VARCHAR(100) NOT NULL                                                       COMMENT ''[DADO_PESSOAL] Bairro do endereco do cliente'',
              nu_cep                      VARCHAR(8)   NOT NULL                                                       COMMENT ''[DADO_PESSOAL] Numero CEP (Codigo de Enderecamento Postal) referente ao endereco do cliente'',
              id_usuario_criacao          BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
              dt_criacao                  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
              id_usuario_atualizacao      BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
              dt_atualizacao              TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
              CONSTRAINT pk_clieende PRIMARY KEY (id_cliente_endereco),
              CONSTRAINT uk_clieende_01 UNIQUE (id_cliente),
              CONSTRAINT fk_cliente_clieende FOREIGN KEY (id_cliente) REFERENCES boacompra_adm.tb_cliente (id_cliente),
              CONSTRAINT fk_municipio_clieende FOREIGN KEY (id_municipio) REFERENCES boacompra_adm.tb_municipio (id_municipio)
          ) COMMENT = ''[DADO_PESSOAL] Armazena os enderecos dos clientes''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_cliente_endereco criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_cliente_endereco já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_CLIEENDE_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_clieende_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_clieende_01 ON boacompra_adm.tb_cliente_endereco (id_municipio);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_clieende_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_clieende_01 já existe.' AS mensagem;
    END IF;

END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_cliente_endereco();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_cliente_endereco;
