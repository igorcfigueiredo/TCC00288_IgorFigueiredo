DROP TABLE IF EXISTS bairro CASCADE;
DROP TABLE IF EXISTS municipio CASCADE;
DROP TABLE IF EXISTS ligacao CASCADE;
DROP TABLE IF EXISTS antena;

CREATE TABLE bairro(
bairro_id integer NOT NULL, nome character varying NOT NULL, CONSTRAINT bairro_pk PRIMARY KEY (bairro_id));

CREATE TABLE municipio(
municipio_id integer NOT NULL, nome character varying NOT NULL, CONSTRAINT municipio_pk PRIMARY KEY (municipio_id)) ;

CREATE TABLE antena(
antena_id integer NOT NULL, bairro_id integer NOT NULL, municipio_id integer NOT NULL, 
CONSTRAINT antena_pk PRIMARY KEY (antena_id), CONSTRAINT bairro_fk FOREIGN KEY (bairro_id) REFERENCES bairro (bairro_id), 
CONSTRAINT municipio_fk FOREIGN KEY (municipio_id) REFERENCES municipio (municipio_id));

CREATE TABLE ligacao(
    ligacao_id integer NOT NULL, numero_orig integer NOT NULL, numero_dest integer NOT NULL, antena_orig integer NOT NULL, 
    antena_dest integer NOT NULL, inicio timestamp NOT NULL, fim timestamp NOT NULL, CONSTRAINT ligacao_pk PRIMARY KEY (ligacao_id), 
CONSTRAINT antena_orig_fk FOREIGN KEY (antena_orig) REFERENCES antena (antena_id), 
CONSTRAINT antena_dest_fk FOREIGN KEY (antena_dest) REFERENCES antena (antena_id));

INSERT INTO bairro (bairro_id, nome) VALUES (1, 'mutua');
INSERT INTO bairro (bairro_id, nome) VALUES (2, 'centro');
INSERT INTO bairro (bairro_id, nome) VALUES (3, 'icarai');
INSERT INTO municipio (municipio_id, nome) VALUES (1, 'Sao Goncalo');
INSERT INTO municipio (municipio_id, nome) VALUES (2, 'Niteroi');
INSERT INTO antena (antena_id, bairro_id, municipio_id) VALUES (1, 1, 1);
INSERT INTO antena (antena_id, bairro_id, municipio_id) VALUES (2, 2, 2);
INSERT INTO antena (antena_id, bairro_id, municipio_id) VALUES (3, 3, 2);
INSERT INTO ligacao (ligacao_id, numero_orig, numero_dest, antena_orig, antena_dest, inicio, fim)
    VALUES (1, 12131231, 1231231232, 1, 2, timestamp '2001-09-28 03:00:00', timestamp '2001-09-28 04:00:00');
INSERT INTO ligacao (ligacao_id, numero_orig, numero_dest, antena_orig, antena_dest, inicio, fim)
    VALUES (2, 12131231, 1231231232, 1, 3, timestamp '2001-09-28 03:00:00', timestamp '2001-09-28 05:30:00');


CREATE OR REPLACE FUNCTION duracao_media3(data1 timestamp, data2 timestamp) 
RETURNS TABLE (bairro character varying, municipio character varying, duracao interval) 
AS $BODY$
BEGIN
    RETURN QUERY 
        SELECT b.nome, m.nome, 
                (SELECT SUM(fim - inicio)/count(*) 
                FROM ligacao
                     JOIN antena a1 ON antena_orig = a1.antena_id
                     JOIN antena a2 ON antena_dest = a2.antena_id
                     JOIN bairro b1 ON b1.bairro_id = a1.bairro_id
                     JOIN bairro b2 ON b2.bairro_id = a2.bairro_id
                     JOIN municipio m1 ON m1.municipio_id = a1.municipio_id
                     JOIN municipio m2 ON m2.municipio_id = a2.municipio_id
                WHERE inicio BETWEEN data1 AND data2
                      AND fim BETWEEN data1 AND data2
                      AND (m1.municipio_id = m.municipio_id OR m2.municipio_id = m.municipio_id)
                      AND (b1.bairro_id = b.bairro_id OR b2.bairro_id = b.bairro_id)
                ) AS duracao
        FROM bairro b 
            JOIN antena a ON b.bairro_id = a.bairro_id 
            JOIN municipio m ON m.municipio_id = a.municipio_id
        ORDER BY duracao DESC;
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM duracao_media3(timestamp '2001-09-28 01:00:00', timestamp '2001-09-28 12:00:00');