CREATE OR REPLACE FUNCTION deletaLinhaColuna(i int, j int, x float[][]) RETURNS float[][] 
AS $BODY$
DECLARE
	w float[][];
	z float[];
BEGIN
    FOR i2 in 1..array_length(x, 1) LOOP
        FOR j2 in 1..array_length(x, 2) LOOP
            IF i2 <> i AND j2 <> j THEN
                z := array_append(z, x[i2][j2]);
            END IF;
        END LOOP;
		RAISE NOTICE 'z = %', z;
        w := w || array[z];
        z := '{}';
        RAISE NOTICE 'w = %', w;
    END LOOP;
    RETURN w;
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM deletaLinhaColuna
(2, 2, array[[1.0, 2.0, 3.0], [2.0, 1.0, 3.0]]);