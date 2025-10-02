create database bdBiblioteca;

use bdBiblioteca;

create table Usuarios(
id int primary key auto_increment,
nome varchar(100),
email varchar(100),
senha_hash varchar(255),
role enum ("Bibliotecario","Admin"),
ativo tinyint(1) Default 1,
criado_em datetime default current_timestamp
);



DELIMITER $$

DROP PROCEDURE IF EXISTS sp_usuario_criar $$
CREATE PROCEDURE sp_usuario_criar (
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_senha_hash VARCHAR(255),
    IN p_role VARCHAR(20)  -- precisa ser VARCHAR, não ENUM
)
BEGIN
    INSERT INTO Usuarios (nome, email, senha_Hash, role, ativo, criado_Em)
    VALUES (p_nome, p_email, p_senha_hash, p_role, 1, NOW());
END $$

DELIMITER ;

-- Exemplo de uso (ATENÇÃO: role deve ser 'Adm', não 'Admin')
CALL sp_usuario_criar(
    'Henrique Admin',
    'Henrique@biblioteca.com',
    '1234',
    'Admin'
);

-- CRIANDO A TABELA EDITORA

Create table editora(
id int primary key auto_increment,
nome varchar(150) not null,
criado_em datetime not null default current_timestamp
);

-- CRIANDO A PROCEDURE PARA INSERIR NA TABELA EDITORA

DELIMITER $$

CREATE PROCEDURE sp_editora_criar(
    IN p_nome VARCHAR(100)
)
BEGIN
    INSERT INTO editora (nome,criado_em)
    VALUES (p_nome, NOW());
END $$

DELIMITER ;


-- Criando a tabela genero

Create table genero(
id int primary key auto_increment,
nome varchar(150) not null,
criado_em datetime not null default current_timestamp
);

-- CRIANDO A PROCEDURE PARA INSERIR NA TABELA GENERO

DELIMITER $$

CREATE PROCEDURE sp_genero_criar(
    IN p_nome VARCHAR(100)
)
BEGIN
    INSERT INTO genero (nome,criado_em)
    VALUES (p_nome, NOW());
END $$

DELIMITER ;

-- Criando a tabela autor 

Create table autor(
id int primary key auto_increment,
nome varchar(150) not null,
criado_em datetime not null default current_timestamp
);

-- CRIANDO A PROCEDURE PARA INSERIR NA TABELA AUTOR

DELIMITER $$

CREATE PROCEDURE sp_autor_criar(
    IN p_nome VARCHAR(100)
)
BEGIN
    INSERT INTO autor (nome,criado_em)
    VALUES (p_nome, NOW());
END $$

DELIMITER ;
	
CALL sp_editora_criar(
    'Darkus'
);
CALL sp_genero_criar(
 'Nerf'
);
CALL sp_autor_criar(
'The rock'
);    

-- Criando a tabela livros
    
Create table livros(
id int primary key auto_increment,
titulo varchar(200),
autor int,
editora int,
genero int,
ano int,
isbn varchar(32),
quantidade_total int,
quantidade_disponivel int,
criado_em datetime default current_timestamp
);    

-- Criando  as foreign keys para conectar as tabelas

alter table livros add constraint fk_livros_autor foreign key(autor)
  references autor(id),
  add constraint fk_livros_editora foreign key (editora) 
  references editora(id),
  add constraint fk_livros_genero foreign key (genero)
  references genero(id);
  
-- Criando a  procedure para cadastrar os LIVROS

delimiter $$

CREATE   PROCEDURE sp_livro_criar (
    IN p_titulo VARCHAR(200),
    IN p_autor VARCHAR(100),
    IN p_editora VARCHAR(100),
    IN p_genero VARCHAR(100),
    IN p_ano int,
    IN p_isbn VARCHAR(32),
	IN p_quantidade_total int,
    IN p_capa_arquivo varchar(255)
    )
BEGIN
	
    
    insert into livros 
    (titulo,autor,editora,genero,ano,isbn,capa_arquivo,quantidade_total,quantidade_disponivel,criado_em)
    values
    (p_titulo,p_autor,p_Editora, p_Genero, p_ano,p_isbn,p_capa_arquivo,p_quantidade_total,p_quantidade_total,now());
    

END
$$
delimiter ;

delimiter $$

create  procedure sp_leitor_criar(

p_nome_leitor varchar(30),
p_foto_leitor varchar(255)

)
begin

insert into leitor
(nomeleitor, foto_leitor)
 values(p_nome_leitor,p_foto_leitor);
end $$
delimiter ;

call sp_leitor_criar("Henrique","dsada");



call sp_livro_criar ('Test O começo','Pedro','Panini','Ação',2025,'978-985-00512-3-7',120,80);

-- Criando select para listar as tabelas AUTOR EDITORA E GENERO
delimiter $$
create procedure sp_autor_listar()
begin 
 select id,nome from autor order by nome;
end$$
delimiter ;

delimiter $$
create procedure sp_editora_listar()
begin 
 select id,nome from editora order by nome;
end$$
delimiter ;

delimiter $$
create procedure sp_genero_listar()
begin 
 select id,nome from genero order by nome;
end$$
delimiter ;

delimiter $$

create procedure sp_leitor_listar()
begin
select id_leitor,nomeleitor,foto_leitor from leitor order by nomeleitor;
end$$

delimiter ;


delimiter $$
create procedure sp_livro_listar()
begin
  select
  l.id,
  l.titulo,
  l.autor,
  a.nome As autor_nome,
  l.editora,
  e.nome as editora_nome,
  l.genero,
  g.nome as genero_nome,
  l.ano,
  l.isbn,
  l.quantidade_total,
  l.quantidade_disponivel,
  l.criado_em
  from livros l 
  left join autor   a on a.id = l.autor
  left join editora e on e.id = l.editora
  left join genero  g on g.id = l.genero
  order by l.titulo;
end $$

delimiter ;

delimiter $$
Create procedure sp_usuario_obter_por_email(IN p_email varchar(100))
begin
select id,nome,email, senha_hash,role,ativo from usuarios where email= p_email
limit 1;
end $$
delimiter ;

delimiter $$
create procedure sp_livro_obter(in p_id int)
begin
 select id,titulo,autor,editora,genero,ano,isbn,quantidade_total,quantidade_disponivel, criado_em
 from livros where id = p_id;
 end;

delimiter ;

delimiter $$

create procedure sp_leitor_obter(in p_id int)
begin

select id_leitor,nomeleitor,foto_leitor,foto_leitor,criado_em from leitor where id_leitor = p_id;

end  $$

delimiter ;

delimiter $$
create procedure sp_livro_obter (in p_id int)
begin
select id,titulo,autor,editora,genero,ano, isbn, quantidade_total, quantidade_disponivel, criado_em
from livros where id = p_id;
end;

create procedure sp_genero_obter (in p_id int)
begin
select id,nome,criado_em from genero where id = p_id;
end ;

create procedure sp_editora_obter (in p_id int)
begin
select id,nome,criado_em from editora where id = p_id;
end ;
 
 
 create procedure sp_autor_obter (in p_id int)
begin
select id,nome,criado_em from autor where id = p_id;
end ;
 
 
 delimiter ;
 

delimiter $$
create procedure sp_livro_atualizar (
in p_id int,in p_titulo varchar(200), in p_autor int, in p_editora int,
in p_genero int, in p_ano smallint , in p_isbn varchar(32), in p_novo_total int
)
begin
	Declare v_disp int;   Declare v_total int;
	select quantidade_disponivel, quantidade_total into v_disp, v_total from
	livros where id = p_id for update;
    
	update livros
	set titulo = p_titulo, autor = p_autor, editora = p_editora, genero = p_genero,
	ano = p_ano, isbn = p_isbn,
	quantidade_total = p_novo_total,
	quantidade_disponivel = GREATEST(0, LEAST(p_novo_total, v_disp + (p_novo_total - v_total)))
	where id = p_id;
end; 



 delimiter ;





create procedure sp_livro_excluir (in p_id int)
begin
delete from livros where id = p_id 
end $$

delimiter ;

alter table livros add column capa_arquivo varchar(255) null after isbn;


create table leitor(
id_leitor int primary key auto_increment,
nomeleitor varchar(30),
foto_leitor varchar(255),
criado_em datetime not null default current_timestamp
);



create table emprestimos (
id int primary key auto_increment,
id_leitor int not null,
id_bibliotecario int not null,
data_emprestimo datetime not null default current_timestamp,
data_prevista_devolucao date not null,
data_devolucao_geral datetime null,
status enum('ativo','Finalizado','Parcial') not null default 'ativo'
);

create table emprestimo_itens (
id int primary key auto_increment,
id_emprestimo int not null,
id_livro int not null,
quantidade int not null default 1,
data_devolucao_item datetime null
);

alter table emprestimos 
add constraint fk_feliotr_emp foreign key (id_leitor) references leitor (id_leitor),
add constraint fk_empr_bibli foreign key (id_bibliotecario) references Usuarios(id);


alter table emprestimo_itens
add constraint fk_itens_emp foreign key (id_emprestimo) references emprestimos(id),
add constraint fk_itens_livro foreign key (id_livro) references livros(id);


-- Leitor métodos

delimiter $$
create procedure sp_leitor_criar(p_nome varchar(30), p_foto varchar(255))
begin
   insert into leitor(nomeleitor,foto_leitor,criado_em)
   values (p_nome,p_foto, now());
end  ;
$$
create procedure sp_leitor_obter(p_id int)
begin
select id_leitor, nomeleitor, foto_leitor from Leitor
where id_leitor = p_id ;
end  ;
$$
create procedure sp_leitor_excluir (p_id int)
begin
	delete from leitor where id = p_id ;
end ;
$$

create procedure sp_leitor_editar(p_id int,p_nome varchar(30), p_foto varchar(255))
begin
 update leitor set nomeLeitor = p_nome, foto_leitor = p_foto where id_leitor = p_id ;
end ;

$$

delimiter ;


delimiter $$
create  procedure sp_vitrine_buscar(in p_q varchar(200))
begin
select
l.id,l.titulo, l.autor, l.editora, l.genero, l.ano, l.isbn,
l.capa_arquivo, l.quantidade_total, l.quantidade_disponivel
from livros l where l.quantidade_disponivel > 0 and (p_q is null or p_q = '' or
l.titulo like concat('%', p_q, '%'))
order by l.titulo ;
end $$
delimiter ;

delimiter $$ 
create procedure sp_livro_listar_por_ids (in p_ids text)
begin
/* p_ids : string CSV, ex.: '1,5,9'*/

select l.id, l.titulo, l.capa_arquivo, l.quantidade_disponivel from
livros l where find_in_set(l.id, p_ids) > 0
order by l.titulo ;
end $$

delimiter $$
create  procedure sp_leitor_listar()
begin
  select id_leitor, nomeleitor from leitor  order by nomeleitor ;
end  ;
$$
create  procedure sp_emprestimo_criar(
in p_id_leitor int,
in p_id_bibliotecario int,
in p_data_prevista date,
out p_id_gerado int)
begin
insert into emprestimos(id_leitor, id_bibliotecario, data_prevista_devolucao)
values (p_id_leitor,p_id_bibliotecario, p_data_prevista);
set p_id_gerado = Last_insert_Id();
end $$


create procedure sp_emprestimo_adicionar_item(
in p_id_emprestimo int,
in p_id_livro int,
p_qtd int
)
begin
declare v_disp int ;
if p_qtd is null or p_qtd <= 0 then
	signal sqlstate '45000' set message_text = 'Livro inexistente';
end if;
 select quantidade_disponivel into v_disp from livros where id = p_id_livro for update;
 if v_disp is null then
	signal sqlstate '45000' set message_text='Livro inexistente.';
 end if;
 if v_disp < p_qtd then
	signal sqlstate '45000' set message_text='Estoque insuficiente para este livro.';
	end if;
    
    insert into emprestimo_itens(id_emprestimo,id_livro,quantidade)
    values (p_id_emprestimo,p_id_livro,p_qtd);
    
    update livros set quantidade_disponivel = quantidade_disponivel - p_qtd where id = p_id_livro;
end $$

delimiter ;

use bdbiblioteca;

select * from livros;    
select * from usuarios;
select * from editora;
select * from genero;
select * from autor;
select * from leitor;