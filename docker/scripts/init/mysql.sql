-- Criar banco de dados com charset e collation
CREATE SCHEMA IF NOT EXISTS boacompra_adm
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

-- Criar usuários com senha
CREATE USER boacompra_adm@'%' IDENTIFIED BY 'K&dTsfiI2],0K2/!';
CREATE USER boacompra_app@'%' IDENTIFIED BY 'J|rrNP7252==<[42';

-- Criar roles
CREATE ROLE rl_boacompra_adm;
CREATE ROLE rl_boacompra_app;
CREATE ROLE rl_boacompra_usr;
CREATE ROLE rl_boacompra_aud;
--
CREATE ROLE rl_compliance_publico;
CREATE ROLE rl_compliance_interno;
CREATE ROLE rl_compliance_restrito;
CREATE ROLE rl_compliance_confidencial;

-- Associar usuárioa a role
GRANT rl_boacompra_adm TO boacompra_adm@'%';
GRANT rl_boacompra_app TO boacompra_app@'%';

SET DEFAULT ROLE rl_boacompra_adm TO boacompra_adm@'%';
SET DEFAULT ROLE rl_boacompra_app TO boacompra_app@'%';

-- Conceder permissões
GRANT ALL PRIVILEGES                 ON boacompra_adm.* TO rl_boacompra_adm;
GRANT SELECT, INSERT, UPDATE, DELETE ON boacompra_adm.* TO rl_boacompra_app;