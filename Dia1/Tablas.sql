
CREATE TABLE fabricante(
	codigo INT PRIMARY KEY,
	nombre VARCHAR(100)
);

CREATE TABLE producto(
	codigo INT PRIMARY KEY,
	nombre VARCHAR(100),
	precio DOUBLE PRECISION,
	codigo_fabricante INTEGER REFERENCES fabricante(codigo) -- clave foranea
);


