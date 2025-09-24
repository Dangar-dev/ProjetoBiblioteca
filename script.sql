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

CREATE PROCEDURE sp_livro_criar (
    IN p_titulo VARCHAR(200),
    IN p_autor VARCHAR(100),
    IN p_editora VARCHAR(100),
    IN p_genero VARCHAR(100),
    IN p_ano int,
    IN p_isbn VARCHAR(32),
	IN p_quantidade_total int
    )
BEGIN
	DECLARE dAutor INT;
	DECLARE dEditora INT;
	DECLARE dGenero INT;

    
   
    -- Autor
    IF NOT EXISTS (SELECT id FROM autor WHERE nome = p_autor) THEN 
		INSERT INTO autor(nome)
        VALUES(p_autor);
    END IF;
    
    
    SET dAutor := (SELECT id FROM autor WHERE nome = p_autor);
        
    -- Editora
    IF NOT EXISTS (SELECT id FROM editora WHERE nome = p_editora) THEN 
		INSERT INTO editora(nome)
        VALUES(p_editora);
    END IF;
    
    SET dEditora := (SELECT id FROM editora WHERE nome = p_editora);
        
    -- Genero
    IF NOT EXISTS (SELECT id FROM genero WHERE nome = p_genero) THEN 
		INSERT INTO genero(nome)
        VALUES(p_genero);
    END IF;
    
    SET dGenero := (SELECT id FROM genero WHERE nome = p_genero);
    
    insert into livros (titulo,autor,editora,genero,ano,isbn,quantidade_total,quantidade_disponivel,criado_em)
    values(p_titulo,dAutor,dEditora, dGenero, p_ano,p_isbn,p_quantidade_total,p_quantidade_total,now());
    

END
$$
delimiter ;

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
end; $$





create procedure sp_livro_excluir (in p_id int)
begin
delete from livros where id = p_id;
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




alter table emprestimo_itens
add constraint fk_itens_emp foreign key (id_emprestimo) references emprestimos(id),
add constraint fk_itens_livro foreign key (id_livro) references livros(id);

use bdbiblioteca;

select * from livros;    
select * from usuarios;
select * from editora;
select * from genero;
select * from autor;