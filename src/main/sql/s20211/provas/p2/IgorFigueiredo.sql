DROP TABLE IF EXISTS atividade CASCADE;
CREATE TABLE atividade (
    id int NOT NULL,
    nome varchar(40) NOT NULL,
    CONSTRAINT atividade_pk PRIMARY KEY
    (id)
);

DROP TABLE IF EXISTS artista CASCADE;
CREATE TABLE artista (
    id int NOT NULL,
    nome varchar(40) NOT NULL,
    rua varchar(40) NOT NULL,
    cidade varchar(40) NOT NULL,
    estado varchar(40) NOT NULL,
    cep varchar(40) NOT NULL,
    atividade_id int NOT NULL,
    CONSTRAINT artista_pk PRIMARY KEY
    (id),
    CONSTRAINT artista_atividade_fk FOREIGN KEY (atividade_id) REFERENCES atividade (id)
);

DROP TABLE IF EXISTS arena CASCADE;
CREATE TABLE arena (
    id int NOT NULL,
    nome varchar(40) NOT NULL,
    cidade varchar(40) NOT NULL,
    capacidade int NOT NULL,
    CONSTRAINT arena_pk PRIMARY KEY
    (id)
);

DROP TABLE IF EXISTS concerto CASCADE;
CREATE TABLE concerto (
    id int NOT NULL,
    artista_id int NOT NULL,
    arena_id int NOT NULL,
    inicio timestamp NOT NULL,
    fim timestamp NOT NULL,
    preco float NOT NULL,
    CONSTRAINT concerto_pk PRIMARY KEY
    (id),
    CONSTRAINT concerto_artista_fk FOREIGN KEY (artista_id) REFERENCES artista (id),
    CONSTRAINT concerto_arena_fk FOREIGN KEY (arena_id) REFERENCES arena (id)
);



INSERT INTO atividade VALUES (1, 'At1');
INSERT INTO atividade VALUES (2, 'At2');
INSERT INTO atividade VALUES (3, 'At3');
INSERT INTO atividade VALUES (4, 'At4');


INSERT INTO artista VALUES (1, 'Ana', 'asda', 'asdas', 'asaeaw', '21312321', 1);
INSERT INTO artista VALUES (2, 'Alvo', 'asda', 'asdas', 'asaeaw', '21312321', 2);
INSERT INTO artista VALUES (3, 'Alonso', 'asda', 'asdas', 'asaeaw', '21312321', 3);
INSERT INTO artista VALUES (4, 'Aarao', 'asda', 'asdas', 'asaeaw', '21312321', 3);
INSERT INTO artista VALUES (5, 'Amanda', 'asda', 'asdas', 'asaeaw', '21312321', 4);

INSERT INTO ARENA VALUES (1, 'Arena1', 'asda', 1000);
INSERT INTO ARENA VALUES (2, 'Arena2', 'asda', 1000);
INSERT INTO ARENA VALUES (3, 'Arena3', 'asda', 1000);

INSERT INTO CONCERTO VALUES (1, 1, 1, TO_TIMESTAMP('2017-03-31 9:30:20','YYYY-MM-DD HH:MI:SS'), CURRENT_TIMESTAMP, 0.0);

DROP FUNCTION arena_artista_ocupados;
CREATE OR REPLACE FUNCTION arena_artista_ocupados() RETURNS trigger AS $arena_artista_ocupados$
    DECLARE
        arena_ocupada int = 0;
    BEGIN
    
        SELECT COUNT(*) INTO arena_ocupada FROM concerto c
        WHERE
            (c.arena_id = NEW.arena_id OR c.artista_id = NEW.artista_id) AND 
            (NEW.inicio BETWEEN c.inicio AND c.fim 
                OR NEW.fim BETWEEN c.inicio AND c.fim);
        
        IF arena_ocupada <> 0 THEN
            RAISE EXCEPTION 'o artista e/ou a arena ja estao ocupados nessa data';
        END IF;

        RETURN NEW;
    END;
$arena_artista_ocupados$ LANGUAGE plpgsql;

CREATE TRIGGER arena_artista_ocupados BEFORE INSERT ON concerto
    FOR EACH ROW EXECUTE FUNCTION arena_artista_ocupados();

DROP FUNCTION proibido_exclusao_artista;
CREATE OR REPLACE FUNCTION proibido_exclusao_artista() RETURNS trigger AS $proibido_exclusao_artista$
    DECLARE
        qnts_artistas int = 0;
    BEGIN

        SELECT COUNT(*) INTO qnts_artistas FROM artista a
        WHERE
            a.atividade_id = old.atividade_id;
        
        IF qnts_artistas = 1 THEN
            RAISE EXCEPTION 'o artista eh o unico nessa atividade!';
        END IF;

        RETURN OLD;
    END;
$proibido_exclusao_artista$ LANGUAGE plpgsql;

CREATE TRIGGER proibido_exclusao_artista BEFORE DELETE ON artista
    FOR EACH ROW EXECUTE FUNCTION proibido_exclusao_artista();

DELETE FROM artista WHERE id = 1;
DELETE FROM artista WHERE id = 3;
DELETE FROM artista WHERE id = 4;


INSERT INTO concerto VALUES (2, 2, 1, TO_TIMESTAMP('2018-03-31 9:30:20','YYYY-MM-DD HH:MI:SS'), CURRENT_TIMESTAMP, 1.0);
INSERT INTO concerto VALUES (2, 1, 2, TO_TIMESTAMP('2016-03-31 9:30:20','YYYY-MM-DD HH:MI:SS'), CURRENT_TIMESTAMP, 1.0);
INSERT INTO concerto VALUES (2, 2, 2, TO_TIMESTAMP('2018-03-31 9:30:20','YYYY-MM-DD HH:MI:SS'), CURRENT_TIMESTAMP, 1.0);

