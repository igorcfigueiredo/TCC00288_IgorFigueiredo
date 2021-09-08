drop table if exists venda cascade;
drop table if exists produto cascade;
drop table if exists item_venda cascade;
drop table if exists ordem_reposicao cascade;

CREATE TABLE venda(
id int NOT NULL,
data timestamp,
CONSTRAINT venda_pk PRIMARY KEY
    (id)
);

CREATE TABLE produto(
id int NOT NULL, 
nome varchar(40),
preco float,
estoque int,
estoque_minimo int,
estoque_maximo int,
CONSTRAINT produto_pk PRIMARY KEY (id)
);

CREATE TABLE item_venda(
venda_id int NOT NULL,
produto_id int NOT NULL,
qtd int NOT NULL,
CONSTRAINT item_venda_pk PRIMARY KEY (venda_id, produto_id)
);

CREATE TABLE ordem_reposicao(
produto_id int NOT NULL,
qtd int NOT NULL,
CONSTRAINT ordem_reposicao_pk PRIMARY KEY (produto_id)
);

INSERT INTO produto VALUES (1, 'leite', 2.50, 5, 5, 6);
INSERT INTO produto VALUES (2, 'carne bovina', 10.00, 1, 1, 2);
INSERT INTO produto VALUES (3, 'ovos', 2.50, 12, 1, 60);
INSERT INTO produto VALUES (4, 'pão', 3.50, 4, 0, 10);
INSERT INTO produto VALUES (5, 'laranja', 5.00, 12, 12, 12);

CREATE OR REPLACE FUNCTION venda_func() AS $venda_func$
    DECLARE
        produto_estoque int;
        produto_estoqueMax int;
        produto_estoqueMin int;
        tem_ordem int = 0;
        
    BEGIN  
        SELECT 
            p.estoque,
            p.estoque_minimo,
            p.estoque_maximo INTO produto_estoque, produto_estoqueMin, produto_estoqueMax
        FROM produto p WHERE p.id = NEW.produto_id;

        IF produto_estoque - NEW.qtd < produto_estoqueMin THEN
            
            SELECT o.produto_id INTO tem_estoque 
            FROM ordem_reposicao o WHERE o.produto_id = NEW.produto_id;
            
            IF tem_ordem <> 0 THEN
                UPDATE ordem_reposicao SET qtd = qtd + NEW.qtd 
                WHERE produto_id = NEW.produto_id;
            ELSE
                INSERT INTO ordem_reposicao VALUES
                (NEW.produto_id,
                 produto_estoqueMax - (produto_estoque - NEW.qtd)
                );
            END IF;
        END IF;
    END;
$venda_func$ LANGUAGE plpgsql;

CREATE TRIGGER venda_trig AFTER INSERT ON item_venda
    FOR EACH ROW EXECUTE FUNCTION venda_func();

INSERT INTO venda VALUES (1, CURRENT_TIMESTAMP);
INSERT INTO venda VALUES (2, CURRENT_TIMESTAMP);
INSERT INTO item_venda VALUES(1, 1, 3);
INSERT INTO item_venda VALUES(2, 1, 1);
SELECT * from ordem_reposicao; 