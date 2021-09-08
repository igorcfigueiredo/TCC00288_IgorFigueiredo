drop table if exists empregados cascade;
drop table if exists auditoria cascade;

CREATE TABLE auditoria
(id_antes int,
id_depois int,
nome_antes varchar(32),
nome_depois varchar(32),
salario_antes float,
salario_depois float,
data_alteracao timestamp,
alterado_por text );

CREATE TABLE IF NOT EXISTS empregados
(id int,
nome varchar(32),
salario float );

INSERT INTO empregados VALUES (1, 'leite', 2.50);
INSERT INTO empregados VALUES (2, 'carne bovina', 10.00);
INSERT INTO empregados VALUES (3, 'ovos', 2.50);
INSERT INTO empregados VALUES (4, 'pão', 3.50);
INSERT INTO empregados VALUES (5, 'laranja', 5.00);

CREATE OR REPLACE FUNCTION emp_stamp() RETURNS trigger AS $emp_stamp$
    BEGIN
--         -- Check that empname and salary are given
--         IF NEW.nome IS NULL THEN
--             RAISE EXCEPTION 'empname cannot be null';
--         END IF;
--         IF NEW.salario IS NULL THEN
--             RAISE EXCEPTION '% cannot have null salary', NEW.empname;
--         END IF;
-- 
--         -- Who works for us when they must pay for it?
--         IF NEW.salario < 0 THEN
--             RAISE EXCEPTION '% cannot have a negative salary', NEW.empname;
--         END IF;
-- 
--         -- Remember who changed the payroll when
        
        INSERT INTO auditoria
        VALUES
        (old.id,
         new.id,
         old.nome,
         new.nome,
         old.salario,
         new.salario,
         CURRENT_TIMESTAMP,
         CURRENT_USER);

        RETURN NEW;
    END;
$emp_stamp$ LANGUAGE plpgsql;

CREATE TRIGGER emp_stamp BEFORE INSERT OR UPDATE OR DELETE ON empregados
    FOR EACH ROW EXECUTE FUNCTION emp_stamp();

INSERT INTO empregados VALUES (6, 'feijão', 4.50);
UPDATE empregados SET salario = salario * 2; 
DELETE FROM empregados WHERE id = 6;
SELECT * FROM auditoria;