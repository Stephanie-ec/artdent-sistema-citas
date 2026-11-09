-- Delta APF2: Carillas Dentales (precio de referencia por pieza) y asignación a odontólogos
-- Ejecutar sobre db_artdent_apf2. No elimina datos existentes.

INSERT INTO Servicio (idServicio, TipoServicio, Lema, Descripcion, Respuesta, Costo, img, Activo) VALUES
  (8, 'Carillas Dentales',
   'Carillas de porcelana desde S/ 1,500 por pieza.',
   'Carillas de porcelana a medida para corregir forma, color y desgastes. El precio corresponde a una pieza; el total se calcula según el número de piezas.',
   'Indicado para mejorar la estética de dientes manchados, desgastados o con espacios leves.',
   1500.00, 'img/servicios/carillas.png', 1)
ON DUPLICATE KEY UPDATE
  TipoServicio = 'Carillas Dentales',
  Lema = VALUES(Lema),
  Descripcion = VALUES(Descripcion),
  Respuesta = VALUES(Respuesta),
  Costo = 1500.00,
  img = 'img/servicios/carillas.png',
  Activo = 1;

-- Odontóloga Lucía Herrera (si no existe en la base local)
SET @hash_odonto = (SELECT Clave FROM Usuario WHERE DNI = '70096374' LIMIT 1);
INSERT INTO Usuario (Nombre, Apellido, DNI, Telefono, CorreoElectronico, Direccion, FechaNacimiento, Clave, Rol_idRol)
SELECT 'Lucía', 'Herrera Campos', '71458236', '956321478', 'lucia.herrera@artdent.com',
       'Av. Arequipa 1450', '1992-05-14', @hash_odonto, 3
WHERE NOT EXISTS (SELECT 1 FROM Usuario WHERE DNI = '71458236');

SET @lucia = (SELECT idUsuario FROM Usuario WHERE DNI = '71458236' LIMIT 1);
INSERT IGNORE INTO Usuario_Horario (Usuario_idUsuario, Horario_idHorario)
SELECT @lucia, idHorario FROM Horario WHERE idHorario <= 6;
INSERT IGNORE INTO Usuario_Servicio (idUsuario, idServicio, Disponibilidad)
SELECT @lucia, idServicio, 1 FROM Servicio WHERE idServicio IN (1, 4, 5, 7, 8);

-- Rubén Cuadros (id 4)
INSERT IGNORE INTO Usuario_Servicio (idUsuario, idServicio, Disponibilidad) VALUES (4, 8, 1);

SELECT u.idUsuario, CONCAT(u.Nombre, ' ', u.Apellido) AS odontologo,
       s.idServicio, s.TipoServicio, s.Costo
FROM Usuario u
JOIN Usuario_Servicio us ON us.idUsuario = u.idUsuario
JOIN Servicio s ON s.idServicio = us.idServicio
WHERE s.idServicio = 8
ORDER BY u.idUsuario;
