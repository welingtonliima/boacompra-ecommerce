/*
---------------------------------------------------------------------------------------------------
-- MOTIVO:       CARD-001 >> Modelagem do contato do cliente
-- AUTOR:        Welington Lima
-- DATA :        18/06/2024
-- SISTEMA:      Boa Compra - Ecommerce
---------------------------------------------------------------------------------------------------
*/

USE boacompra_adm;

-- +---------------------------------------------------------+--
-- 1. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_cliente_contato;

-- +---------------------------------------------------------+--
-- 2. Criacao da procedure de migration
-- +---------------------------------------------------------+--
DELIMITER //
CREATE PROCEDURE prc_migration_cliente_contato()
BEGIN
    DECLARE v_exists INT;
    DECLARE v_schema_name VARCHAR(128) DEFAULT 'boacompra_adm';
    DECLARE v_table_name  VARCHAR(128) DEFAULT 'tb_cliente_contato';

    -- 1. Criar a tabela TB_CLIENTE_CONTATO
    SELECT COUNT(*) INTO v_exists
    FROM information_schema.tables
    WHERE table_schema = v_schema_name AND table_name = v_table_name;

    IF v_exists = 0 THEN
        SET @sql := '
          CREATE TABLE boacompra_adm.tb_cliente_contato (
             id_cliente_contato           BIGINT       NOT NULL AUTO_INCREMENT                                        COMMENT ''[DADO_PUBLICO] Chave primaria [PK_CLIECONT]. Identificador do contato do cliente'',
             id_cliente                   BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Chave estrangeira [FK_CLIENTE_CLIECONT] e parte da chave unica [UK_CLIECONT_01]. Identificador do cliente'',
             nu_ddd                       TINYINT      NOT NULL                                                       COMMENT ''[DADO_PESSOAL] Parte da chave unica [UK_CLIECONT_01]. Numero do DDD (Discagem Direta a Distancia) do contato do cliente'',
             nu_telefone                  VARCHAR(20)  NOT NULL                                                       COMMENT ''[DADO_PESSOAL] Parte da chave unica [UK_CLIECONT_01]. Numero de contato do cliente'',
             tp_contato                   TINYINT      NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Parte da chave unica [UK_CLIECONT_01]. Indica o tipo de telefone. Aceita os valores: 1 (Celular), 2 (Fixo), 3 (Comercial), 4 (Whatsapp).'',
             in_principal                 TINYINT      NOT NULL DEFAULT 1                                             COMMENT ''[DADO_PUBLICO] Indica se o contato e principal. Aceita os valores: 0 (Nao) e 1(Sim)'',
             id_usuario_criacao           BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do usuario responsavel pela criacao do registro'',
             dt_criacao                   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP                             COMMENT ''[DADO_PUBLICO] Data e hora de criacao do registro'',
             id_usuario_atualizacao       BIGINT       NOT NULL                                                       COMMENT ''[DADO_PUBLICO] Identificador do ultimo usuario que atualizou o registro'',
             dt_atualizacao               TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT ''[DADO_PUBLICO] Data e hora da ultima atualizacao do registro'',
             CONSTRAINT pk_cliecont PRIMARY KEY (id_cliente_contato),
             CONSTRAINT uk_cliecont_01 UNIQUE (id_cliente, nu_ddd, nu_telefone, tp_contato),
             CONSTRAINT fk_cliente_cliecont FOREIGN KEY (id_cliente) REFERENCES boacompra_adm.tb_cliente (id_cliente),
             CONSTRAINT ck_cliecont_01 CHECK (in_principal IN (0,1))
          ) COMMENT = ''[DADO_PESSOAL] Armazena os contatos dos clientes''
            ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Tabela boacompra_adm.tb_cliente_contato criada com sucesso!' AS mensagem;
    ELSE
        SELECT 'Tabela boacompra_adm.tb_cliente_contato já existe.' AS mensagem;
    END IF;

    -- 2. Criar o indice IDX_CLIECONT_01
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_cliecont_01';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_cliecont_01 ON boacompra_adm.tb_cliente_contato (id_cliente);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_cliecont_01 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_cliecont_01 já existe.' AS mensagem;
    END IF;

    -- 3. Criar o indice IDX_CLIECONT_02
    SELECT COUNT(1) INTO v_exists FROM information_schema.statistics
    WHERE table_schema = v_schema_name AND table_name = v_table_name AND index_name = 'idx_cliecont_02';
    IF v_exists = 0 THEN
        SET @sql := '
          CREATE INDEX idx_cliecont_02 ON boacompra_adm.tb_cliente_contato (id_cliente, in_principal);
        ';
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT 'Índice idx_cliecont_02 criado.' AS mensagem;
    ELSE
        SELECT 'Índice idx_cliecont_02 já existe.' AS mensagem;
    END IF;
END;
//
DELIMITER ;

-- +---------------------------------------------------------+--
-- 3. Execucao da procedure de migration
-- +---------------------------------------------------------+--
CALL prc_migration_cliente_contato();

-- +---------------------------------------------------------+--
-- 4. Exclusao da procedure de migration
-- +---------------------------------------------------------+--
DROP PROCEDURE IF EXISTS prc_migration_cliente_contato;
