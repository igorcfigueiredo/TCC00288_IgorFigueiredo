drop table if exists campeonato cascade;
CREATE TABLE campeonato (
    codigo text NOT NULL,
    nome TEXT NOT NULL,
    ano integer NOT NULL,
    CONSTRAINT campeonato_pk PRIMARY KEY
    (codigo)
);

drop table if exists time_ cascade;
CREATE TABLE time_ (
    sigla text NOT NULL,
    nome TEXT NOT NULL,
    CONSTRAINT time_pk PRIMARY KEY
    (sigla)
);

drop table if exists jogo cascade;
CREATE TABLE jogo (
    campeonato TEXT NOT NULL,
    numero integer NOT NULL,
    time1 TEXT NOT NULL,
    time2 TEXT NOT NULL,
    gols1 integer NOT NULL,
    gols2 integer NOT NULL,
    data_ DATE NOT NULL,
    CONSTRAINT jogo_pk PRIMARY KEY
    (campeonato, numero),
    CONSTRAINT jogo_campeonato_fk FOREIGN KEY
    (campeonato) REFERENCES campeonato (codigo),
    CONSTRAINT jogo_time_fk1 FOREIGN KEY
    (time1) REFERENCES time_ (sigla),
    CONSTRAINT jogo_time_fk2 FOREIGN KEY
    (time2) REFERENCES time_ (sigla)
);

INSERT INTO time_ (sigla, nome) VALUES ('FLA', 'Flamengo');
INSERT INTO time_ (sigla, nome) VALUES ('VAS', 'Vasco');
INSERT INTO campeonato (codigo, nome, ano) VALUES ('teste', 'Teste', 2021);
INSERT INTO jogo (campeonato, numero, time1, time2, gols1, gols2, data_) VALUES ('teste', 1, 'FLA', 'VAS', 1, 0, NOW());
INSERT INTO jogo (campeonato, numero, time1, time2, gols1, gols2, data_) VALUES ('teste', 3, 'FLA', 'VAS', 1, 0, NOW());
-- INSERT INTO jogo (campeonato, numero, time1, time2, gols1, gols2, data_) VALUES ('teste', 2, 'VAS', 'FLA', 2, 1, NOW());


CREATE OR REPLACE FUNCTION computaTabela5(id_campeonato text, pos_inicial int, pos_final int)
RETURNS TABLE (time_ text, pontos bigint, num_vitorias bigint)
AS $BODY$
BEGIN
    RETURN QUERY 
    SELECT t.nome, 
        (   
            (SELECT
                SUM(
                    CASE 
                        WHEN (gols1 > gols2) THEN 3 
                        WHEN (gols1 = gols2) THEN 1 
                        ELSE 0 
                    END
                ) as pontos
            FROM jogo WHERE campeonato = id_campeonato AND time1 = t.sigla)
            +
            (SELECT 
                SUM(
                    CASE 
                        WHEN (gols2 > gols1) THEN 3 
                        WHEN gols1 = gols2 THEN 1 
                        ELSE 0 
                    END
                ) as pontos
            FROM jogo WHERE campeonato = id_campeonato AND time2 = t.sigla OR 0)
        )
        as pontos,
        (   
            (SELECT
                SUM(
                    CASE 
                        WHEN (gols1 > gols2) THEN 1  
                        ELSE 0 
                    END
                ) as pontos
            FROM jogo WHERE campeonato = id_campeonato AND time1 = t.sigla)
            +
            (SELECT 
                SUM(
                    CASE 
                        WHEN (gols2 > gols1) THEN 1 
                        ELSE 0 
                    END
                ) as pontos
            FROM jogo WHERE campeonato = id_campeonato AND time2 = t.sigla)
        )
        as num_vitorias
    FROM time_ t ORDER BY pontos DESC, num_vitorias DESC LIMIT pos_final OFFSET pos_inicial;
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM computaTabela5('teste', 0, 2);