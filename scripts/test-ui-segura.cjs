// Comportamiento de los scripts reales con dobles DOM. No sustituye pruebas de navegador.
const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),vm=require('node:vm'),path=require('node:path');
const leer=f=>fs.readFileSync(path.join(__dirname,'../src/main/webapp/js',f),'utf8');
class Elemento {
 constructor(tag){this.tag=tag;this.children=[];this.textContent='';this.style={};}
 set innerHTML(_){throw new Error('No debe interpretar HTML de respuestas');}
 appendChild(node){this.children.push(node);}
}
test('F-15: payload se conserva como texto y no como HTML',()=>{
 const window={},document={createElement:t=>new Elemento(t),createTextNode:t=>({textContent:t})};
 vm.runInNewContext(leer('chat-render.js'),{window,document});const el=new Elemento('div');
 const payload='<img src=x onerror=alert(1)>';
 window.artdentRenderBot(el,{mensaje:payload,servicio:{id:1,nombre:payload,costo:100}},'/ArtDent');
 assert.equal(el.textContent,payload);const link=el.children.find(n=>n.tag==='a');
 assert.equal(link.textContent,payload);assert.equal(link.href,'/ArtDent/ServicioController?action=cargar&id=1');
 const invalido=new Elemento('div');window.artdentRenderBot(invalido,{mensaje:'Dental',servicio:{id:'javascript:alert(1)'}},'/ArtDent');
 assert.equal(invalido.children.length,0);
});
for(const [name,persisted,type,expected] of [['bfcache',true,'navigate',1],['atras',false,'back_forward',1],['recarga',false,'reload',0]]) {
 test('Sesion: '+name,()=>{
  let handler,reloads=0;const window={addEventListener:(_,fn)=>handler=fn,location:{reload:()=>reloads++}};
  vm.runInNewContext(leer('session-guard.js'),{window,performance:{getEntriesByType:()=>[{type}]}});
  handler({persisted});assert.equal(reloads,expected);
 });
}
test('F-01: domingo bloqueado y sabado con turno reducido',()=>{
 let ready,change;const fecha={value:'2026-11-08',setCustomValidity(v){this.error=v;},addEventListener(_,fn){change=fn;}};
 const hora={};const document={getElementById:id=>id==='new-date'?fecha:hora,addEventListener:(_,fn)=>ready=fn};
 vm.runInNewContext(leer('reprogramacion.js'),{document});ready();assert.match(fecha.error,/domingos/);
 fecha.value='2026-11-14';change();assert.equal(fecha.error,'');assert.equal(hora.min,'09:00');assert.equal(hora.max,'12:15');
});
