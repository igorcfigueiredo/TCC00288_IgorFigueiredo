drop table if exists time_ cascade;
CREATE TABLE produto (
    codigo varchar NOT NULL,
    descricao varchar NOT NULL,
    preco float NOT NULL,
    CONSTRAINT produto_pk PRIMARY KEY
    (codigo)
);

insert into produto(codigo, descricao, preco) values ('001', 'teste', 10.0);
insert into produto(codigo, descricao, preco) values ('002', 'teste', 15.0);

CREATE OR REPLACE FUNCTION totalProduto(p_produtos varchar[], p_qtds integer[]) RETURNS float
AS $BODY$
BEGIN
    RETURN SELECT SUM(p.preco * t.qtd) FROM produto p 
            WHERE t.codigo = p.codigo
            JOIN SELECT t.* from unnest(p_produtos, p_qtds) as t(codigo,qtd)
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM totalProduto(['001', '002'],[2,3])