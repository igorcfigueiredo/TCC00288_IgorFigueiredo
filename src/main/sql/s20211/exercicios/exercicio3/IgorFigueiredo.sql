CREATE OR REPLACE FUNCTION multiplicaMatrizes(x float[][], y float[][]) RETURNS float[][] 
AS $BODY$
DECLARE
	w float[][];
	z float[];
	soma float;
BEGIN
    IF array_length(x, 2) <> array_length(y, 1) THEN
        RAISE EXCEPTION 'Numero de colunas de x e linhas de y devem ser iguais';
    END IF;
    FOR i in 1..array_length(x, 1) LOOP
        FOR j in 1..array_length(y, 2) LOOP
            soma := 0;
            FOR v in 1..array_length(x,2) LOOP
                RAISE NOTICE 'i = %', i;
                RAISE NOTICE 'j = %', j;
                RAISE NOTICE 'v = %', v;
                soma := soma + x[i][v] * y[v][j];
            END LOOP;
            z := array_append(z, soma);
        END LOOP;
        w := w || array[z];
        z := '{}';
        RAISE NOTICE 'w = %', w;
    END LOOP;
    RETURN w;
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM multiplicaMatrizes
(array[[1.0, 2.0], [2.0, 1.0]], array[[2.0, 1.0], [1.0, 2.0]]);