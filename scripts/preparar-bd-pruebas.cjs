// Solo genera SQL para una base descartable. No se conecta ni modifica MySQL.
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'..');
const source=fs.readFileSync(path.join(root,'src/main/java/pe/edu/utp/bd/db_artdent_apf2_completo.sql'),'utf8');
if(!source.includes('USE db_artdent_apf2;'))throw new Error('Nombre de BD canonica inesperado; revisar antes de generar.');
fs.mkdirSync(path.join(root,'target'),{recursive:true});
fs.writeFileSync(path.join(root,'target/test-bootstrap.sql'),source.replaceAll('db_artdent_apf2','db_artdent_apf2_test'));
process.stdout.write('Generado target/test-bootstrap.sql. Al importarlo se reinicia SOLO db_artdent_apf2_test.\n');
