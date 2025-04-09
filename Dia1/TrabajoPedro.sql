-- Database: claset2

-- DROP DATABASE IF EXISTS claset2;

CREATE DATABASE claset2
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'es-ES'
    LC_CTYPE = 'es-ES'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

	create table fabricante (
	codigo serial primary key,
	nombre varchar(100)
	);

	create table producto (
	codigo serial primary key,
	nombre varchar(100),
	precio double precision,
	codigo_fabricante int,
	foreign key (codigo_fabricante) references fabricante(codigo)
	);

	insert into fabricante (codigo, nombre) values
	(1,'Asus'),
	(2,'Lenovo'),
	(3,'Hewlett-Packard'),
	(4,'Samsung'),
	(5,'Seagate'),
	(6,'Crucial'),
	(7,'Gigabyte'),
	(8,'Huawei'),
	(9,'Xiaomi');

	insert into producto (codigo, nombre, precio, codigo_fabricante) values
	(1, 'Disco duro SATA3 1TB', 86.99, 5),
	(2, 'Memoria RAM DDR4 8GB', 120, 6),
	(3, 'Disco SSD 1 TB', 150.99, 4),
	(4, 'GeForce GTX 1050Ti', 185, 7),
	(5, 'GeForce GTX 1080 Xtreme', 755, 6),
	(6, 'Monitor 24 LED Full HD', 202, 1),
	(7, 'Monitor 27 LED Full HD', 245.99, 1),
	(8, 'Portátil Yoga 520', 559, 2),
	(9, 'Portátil Ideapd 320', 444, 2),
	(10, 'Impresora HP Deskjet 3720', 59.99, 3),
	(11, 'Impresora HP Laserjet Pro M26nw', 180, 3);



	