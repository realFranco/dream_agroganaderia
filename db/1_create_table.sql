CREATE TABLE Almacen (
  id_almacen     uuid NOT NULL, 
  nombre_almacen varchar(128) NOT NULL UNIQUE, 
  PRIMARY KEY (id_almacen));
  
COMMENT ON TABLE Almacen IS 'Un almacen tambien podría ser una sucursal, en caso de contener otras más.';

COMMENT ON COLUMN Almacen.nombre_almacen IS 'Por ejemplo: "almacen central"';

CREATE TABLE Blog (
  id_blog      uuid NOT NULL, 
  id_usuario   uuid, 
  titulo       varchar(256) NOT NULL UNIQUE, 
  contenido    varchar(255) NOT NULL, 
  creacion     time NOT NULL, 
  modificacion time NOT NULL, 
  eliminado    bool NOT NULL, 
  blog_slug    varchar(64) NOT NULL UNIQUE, 
  PRIMARY KEY (id_blog));
  
COMMENT ON TABLE Blog IS 'El atributo contenido podría ser un texto enriquecido, hasta podría guardarse como una estructura XML para definir una estructura al momento de renderizar.';

CREATE TABLE Camapha_Email (
  id_camp_email     uuid NOT NULL, 
  id_usuario        uuid, 
  estadistica_envio json NOT NULL, 
  contenido         json NOT NULL, 
  PRIMARY KEY (id_camp_email));
  
COMMENT ON COLUMN Camapha_Email.contenido IS 'Contenido general de un correo:

- Subject
- Reply to addrs
- Sender email
- Sender name
- Template name';

CREATE TABLE Etiqueta (
  id_etiqueta uuid NOT NULL, 
  nombre      varchar(32) NOT NULL, 
  id_producto uuid, 
  id_blog     uuid, 
  PRIMARY KEY (id_etiqueta));
  
CREATE TABLE Producto (
  id_producto   uuid NOT NULL, 
  id_usuario    uuid, 
  nombre        varchar(255) NOT NULL, 
  contenido     varchar(255) NOT NULL, 
  creado        time NOT NULL, 
  editado       time NOT NULL, 
  eliminado     bool NOT NULL, 
  slug_producto varchar(64) NOT NULL UNIQUE, 
  PRIMARY KEY (id_producto));
  
COMMENT ON COLUMN Producto.contenido IS 'Este attributo definirá el contenido del producto y sus especificaciones.';

COMMENT ON COLUMN Producto.slug_producto IS 'Este slug será público al cliente.';

CREATE TABLE Producto_Almacen (
  id_producto    uuid NOT NULL, 
  id_almacen     uuid NOT NULL, 
  disponibilidad bool NOT NULL, 
  cantidad       int4 NOT NULL, 
  costo          int4 NOT NULL, 
  PRIMARY KEY (id_producto, 
  id_almacen));
  
COMMENT ON TABLE Producto_Almacen IS 'En un almacen o sucursal el producto puede otro valor o disponibilidad.';

COMMENT ON COLUMN Producto_Almacen.costo IS 'El costo puede estar representado en una sola moneda o referencia, existirán métodos en capas menos abstractas (o superioes) a estas que definan el valor en otras monedas o referencias.';

CREATE TABLE Recurso (
  id_recurso  uuid NOT NULL, 
  id_blog     uuid, 
  id_producto uuid, 
  nombre      varchar(64) NOT NULL, 
  tipo        varchar(32) NOT NULL, 
  creado      time NOT NULL, 
  posicion    int4, 
  componente  varchar(64) NOT NULL, 
  ruta        varchar(64) NOT NULL UNIQUE, 
  PRIMARY KEY (id_recurso));
  
COMMENT ON COLUMN Recurso.posicion IS 'Indica la posición del recurso que será renderizado, solo aparecerá cuando el componente tenga un conjunto de recursos a mostrar.

Por ejemplo un producto para verder consta de varias imágenes.';

COMMENT ON COLUMN Recurso.componente IS 'Dejar el nombre del componente aquí ahorraría joins e inserciones, pero sobrecargaría a la base de datos cuando se debe editar este campo, pues deberá hacerse para todos los recursos que posean este campo.';

CREATE TABLE Solicita_Producto (
  id_cliente          uuid NOT NULL, 
  id_usuario          uuid, 
  estado              int4 NOT NULL, 
  datos_compra        json NOT NULL, 
  slug_factura_compra varchar(64) NOT NULL UNIQUE, 
  PRIMARY KEY (id_cliente));
  
COMMENT ON COLUMN Solicita_Producto.estado IS 'Cada número tendrá un valor asociado a cada solicitud.

Un número menor indica estado de solicitud "por procesar" o "en espera". En caso de haber comprado el producto la solicitud estará en una prioridad aún mayor.';

COMMENT ON COLUMN Solicita_Producto.datos_compra IS 'Indica cantidad del producto, cesta de elementos, fecha de solicitud, fecha de entraga, cancelación.';

COMMENT ON COLUMN Solicita_Producto.slug_factura_compra IS 'El cliente puede establecer un contacto más cercano con su solicitud de compra. Puede ver el estatus actual del producto/cesta de compra.';

CREATE TABLE Usuario (
  id_usuario   uuid NOT NULL, 
  rol          varchar(32) NOT NULL, 
  correo       varchar(255) NOT NULL UNIQUE, 
  pass         varchar(255) NOT NULL, 
  nombre       varchar(64) NOT NULL, 
  apellido     varchar(255) NOT NULL, 
  creado       time NOT NULL, 
  eliminado    bool NOT NULL, 
  editado      time NOT NULL, 
  slug_usuario varchar(64) NOT NULL UNIQUE, 
  PRIMARY KEY (id_usuario));
  
COMMENT ON COLUMN Usuario.pass IS 'Este attr. deberá entrar a un hash antes de ser guardado correctamente dentro de una fila de la tabla.';

ALTER TABLE Camapha_Email ADD CONSTRAINT FKCamapha_Em765692 FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario);

ALTER TABLE Solicita_Producto ADD CONSTRAINT FKSolicita_P582675 FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario);

ALTER TABLE Producto_Almacen ADD CONSTRAINT FKProducto_A479949 FOREIGN KEY (id_producto) REFERENCES Producto (id_producto) ON UPDATE Cascade ON DELETE Cascade;

ALTER TABLE Producto_Almacen ADD CONSTRAINT FKProducto_A550411 FOREIGN KEY (id_almacen) REFERENCES Almacen (id_almacen) ON UPDATE Cascade ON DELETE Cascade;

ALTER TABLE Etiqueta ADD CONSTRAINT blog_con_etiquetas FOREIGN KEY (id_blog) REFERENCES Blog (id_blog) ON UPDATE Cascade ON DELETE Cascade;

ALTER TABLE Recurso ADD CONSTRAINT blog_con_recursos FOREIGN KEY (id_blog) REFERENCES Blog (id_blog) ON UPDATE Cascade ON DELETE Cascade;

ALTER TABLE Etiqueta ADD CONSTRAINT producto_con_etiquetas FOREIGN KEY (id_producto) REFERENCES Producto (id_producto) ON UPDATE Cascade ON DELETE Cascade;

ALTER TABLE Recurso ADD CONSTRAINT producto_con_recursos FOREIGN KEY (id_producto) REFERENCES Producto (id_producto) ON UPDATE Cascade ON DELETE Cascade;

ALTER TABLE Blog ADD CONSTRAINT usuario_crea_blog FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON UPDATE Cascade ON DELETE Cascade;

ALTER TABLE Producto ADD CONSTRAINT usuario_crea_producto FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario) ON UPDATE Cascade ON DELETE Cascade;

