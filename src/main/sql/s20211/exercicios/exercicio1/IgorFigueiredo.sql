DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table pessoa(
nome varchar,
endereco varchar
);

insert into pessoa values ('nome', 'endereco');
insert into pessoa values ('nome2', 'endereco2');
insert into pessoa values ('nome3', 'endereco3');

select * from pessoa;
