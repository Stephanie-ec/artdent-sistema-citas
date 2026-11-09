// Genera las mismas definiciones del SQL canonico, sin borrar tablas ni datos.
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const dir = path.join(root, 'src/main/java/pe/edu/utp/bd');
const source = fs.readFileSync(path.join(dir, 'db_artdent_apf2_completo.sql'), 'utf8');
const names = ['sp_iniciosesion', 'sp_eliminarUsuario', 'sp_listarUsuarios',
  'sp_ListarCitasPorUsuario', 'sp_ListarReservasPorUsuario', 'sp_crearreserva',
  'sp_registrarcita', 'ps_ReprogramarReserva', 'ps_ReprogramarCita'];
const extra = [...source.matchAll(/CREATE PROCEDURE\s+`?(sp_artdent_\w+)`?\s*\(/g)].map(x => x[1]);
const routines = [...new Set([...extra, ...names])].map(name => {
  const pattern = new RegExp('CREATE PROCEDURE `?' + name + '`?\\s*\\([\\s\\S]*?END;;', 'i');
  const match = source.match(pattern);
  if (!match) throw new Error('Rutina ausente: ' + name);
  return 'DROP PROCEDURE IF EXISTS `' + name + '`;;\n' + match[0];
}).join('\n\n');
const table = source.match(/CREATE TABLE CorrelativoComprobante\s*\([\s\S]*?ENGINE=InnoDB;/);
const header = `-- Delta no destructivo. Seleccione la BD correcta con USE antes de ejecutarlo.
-- Detener la aplicacion y hacer respaldo antes de cambiar rutinas. No contiene datos demo.
DELIMITER ;;
DROP PROCEDURE IF EXISTS sp_artdent_migrarActivo;;
CREATE PROCEDURE sp_artdent_migrarActivo()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'Usuario' AND COLUMN_NAME = 'Activo') THEN
    ALTER TABLE Usuario ADD COLUMN Activo TINYINT(1) NOT NULL DEFAULT 1;
  END IF;
END;;
CALL sp_artdent_migrarActivo();;
DROP PROCEDURE sp_artdent_migrarActivo;;
DELIMITER ;
`;
const counter = table ? table[0].replace('CREATE TABLE ', 'CREATE TABLE IF NOT EXISTS ') + `
INSERT INTO CorrelativoComprobante(Serie,Ultimo)
SELECT Serie, COALESCE(MAX(CAST(Numero AS UNSIGNED)),0) FROM Comprobante GROUP BY Serie
ON DUPLICATE KEY UPDATE Ultimo=GREATEST(Ultimo,VALUES(Ultimo));
INSERT IGNORE INTO CorrelativoComprobante VALUES('B001',0);
` : '';
fs.writeFileSync(path.join(dir, 'update_apf2_fallas.sql'), header + counter + '\nDELIMITER ;;\n' + routines + '\nDELIMITER ;\n');
