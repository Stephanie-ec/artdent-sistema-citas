// Recorrido completo del sistema como lo haría el profesor en la exposición.
// Cada paso guarda una captura en e2e/capturas/ (sirven como evidencia para el informe).
const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const CAP = path.join(__dirname, 'capturas');
fs.mkdirSync(CAP, { recursive: true });
let n = 0;
const foto = (page, nombre) => page.screenshot({ path: path.join(CAP, `${String(++n).padStart(2, '0')}-${nombre}.png`), fullPage: true });

// Datos de la corrida: DNIs nuevos cada vez (nunca se repiten entre corridas)
const sufijo = String(Date.now()).slice(-5);
const ODO = { dni: '61' + sufijo + '1', nombre: 'Carla', apellido: 'Mendoza Ríos' };
const SEC = { dni: '61' + sufijo + '2', nombre: 'Patricia', apellido: 'Salas Vega', clave: 'Secretaria2026' };
const PAC = { dni: '61' + sufijo + '3', nombre: 'Sofía', apellido: 'Ramírez Cueva', telefono: '987654321', correo: 'sofia.demo@gmail.com' };
const ADMIN = { dni: '48223344', clave: '123' };

function proximoLunes() {
  const d = new Date(); d.setDate(d.getDate() + ((8 - d.getDay()) % 7 || 7) + 7);
  return d.toISOString().slice(0, 10);
}
const FECHA = proximoLunes();
let codigoReserva = '';

// Elige la opción de un <select> cuyo texto contiene "texto"
async function elegir(page, selector, texto) {
  const valor = await page.locator(`${selector} option`, { hasText: texto }).first().getAttribute('value');
  await page.selectOption(selector, valor);
}

async function login(page, dni, clave) {
  await page.goto('iniciosesion.jsp');
  await page.fill('#document', dni);
  await page.fill('#password', clave);
  await page.click('button[type="submit"]');
}
async function salir(page) {
  await page.goto('CerrarSesionController');
}

test.describe.serial('Recorrido Art Dent', () => {

  test('1. Administrador crea un odontólogo y una secretaria', async ({ page }) => {
    await login(page, ADMIN.dni, ADMIN.clave);
    await page.goto('UsuarioController?action=list');
    await foto(page, 'admin-usuarios');

    for (const [u, rol, clave] of [[ODO, 'Odontologo', 'Odonto2026'], [SEC, 'Secretaria', SEC.clave]]) {
      await page.goto('UsuarioController?action=list');
      await page.fill('#nombre', u.nombre);
      await page.fill('#apellido', u.apellido);
      await page.fill('#dni', u.dni);
      await page.fill('#telefono', '9' + u.dni);
      await page.fill('#email', `${u.nombre.toLowerCase()}.${u.dni}@artdent.com`);
      await page.fill('#direccion', 'Jr. Chiclayo 268');
      await page.fill('#fechanacimiento', '1990-05-10');
      await elegir(page, '#rol', rol);
      await page.fill('#clave', clave);
      await page.click('form[action="UsuarioController?action=add"] button[type="submit"]');
      await expect(page.locator('body')).toContainText(u.apellido);
    }
    await foto(page, 'admin-usuarios-creados');
  });

  test('2. Administrador asigna horario y servicio al odontólogo nuevo', async ({ page }) => {
    await login(page, ADMIN.dni, ADMIN.clave);
    await page.goto('UsuarioController?action=disponibilidad');
    await elegir(page, '#selectOdontologo', ODO.apellido);
    await page.waitForLoadState('networkidle');
    for (const cb of await page.locator('input[name="horarios"]').all()) await cb.check();
    await page.locator('label', { hasText: /Limpieza/i }).first().click();
    await foto(page, 'admin-disponibilidad');
    await page.click('form[action="UsuarioController?action=guardarDisponibilidad"] button[type="submit"]');
    await page.waitForLoadState('networkidle');
    await foto(page, 'admin-disponibilidad-guardada');
    await salir(page);
  });

  test('3. Paciente reserva y ve al odontólogo nuevo', async ({ page }) => {
    await page.goto('ServicioController?action=formreservaa');
    await page.fill('#nombre', PAC.nombre);
    await page.fill('#apellido', PAC.apellido);
    await page.fill('#dni', PAC.dni);
    await page.fill('#telefono', PAC.telefono);
    await page.fill('#correo', PAC.correo);
    await elegir(page, '#motivo', 'Limpieza');
    await page.fill('#fecha', FECHA);
    await page.dispatchEvent('#fecha', 'change');
    await page.selectOption('#hora', '10:00');
    await expect(page.locator('#medico option', { hasText: ODO.apellido })).toHaveCount(1, { timeout: 15000 });
    await elegir(page, '#medico', ODO.apellido);
    await foto(page, 'paciente-reserva');
    await page.click('#btnConfirmarReserva');
    await expect(page.locator('body')).toContainText('ART-RES-');
    codigoReserva = (await page.locator('body').innerText()).match(/ART-RES-\d{5}/)[0];
    await foto(page, 'paciente-codigo-reserva');
  });

  test('4. Paciente envía su comprobante Yape/Plin', async ({ page, context }) => {
    // Misma sesión del navegador: la reserva es "propia"
    await page.goto('ServicioController?action=formreservaa');
    await page.fill('#nombre', PAC.nombre); await page.fill('#apellido', PAC.apellido); await page.fill('#dni', PAC.dni);
    await page.fill('#telefono', PAC.telefono); await page.fill('#correo', PAC.correo);
    await elegir(page, '#motivo', 'Limpieza');
    await page.fill('#fecha', FECHA); await page.dispatchEvent('#fecha', 'change');
    await page.selectOption('#hora', '11:00');
    await expect(page.locator('#medico option', { hasText: ODO.apellido })).toHaveCount(1, { timeout: 15000 });
    await elegir(page, '#medico', ODO.apellido);
    await page.click('#btnConfirmarReserva');
    await expect(page.locator('body')).toContainText('ART-RES-');
    codigoReserva = (await page.locator('body').innerText()).match(/ART-RES-\d{5}/)[0];

    await page.click('a:has-text("Enviar comprobante")');
    await expect(page.locator('#codigo')).toBeVisible();
    await page.selectOption('#canal', 'YAPE');
    await page.fill('#codigo', '12345678');
    await page.fill('#nombre', `${PAC.nombre} ${PAC.apellido}`);
    await page.fill('#dni', PAC.dni);
    // Comprobante de prueba: imagen PNG generada en el navegador
    const png = await page.evaluate(() => {
      const c = document.createElement('canvas'); c.width = 400; c.height = 300;
      const g = c.getContext('2d'); g.fillStyle = '#742284'; g.fillRect(0, 0, 400, 300);
      g.fillStyle = '#fff'; g.font = '28px sans-serif'; g.fillText('Yapeaste S/ 40.00', 60, 150);
      return c.toDataURL('image/png').split(',')[1];
    });
    await page.setInputFiles('input[type="file"]', { name: 'yape.png', mimeType: 'image/png', buffer: Buffer.from(png, 'base64') });
    await foto(page, 'paciente-comprobante');
    await page.click('form[enctype="multipart/form-data"] button');
    await expect(page.locator('.alert-success')).toBeVisible();
    await foto(page, 'paciente-comprobante-enviado');
  });

  test('5. Secretaria nueva verifica el pago y aprueba la reserva', async ({ page }) => {
    await login(page, SEC.dni, SEC.clave);
    await page.goto('PagoManualController');
    await foto(page, 'secretaria-pagos-pendientes');
    const fila = page.locator('form:has(button:has-text("Aprobar pago"))').first();
    await fila.locator('input[name="verificado"]').check();
    await fila.locator('button:has-text("Aprobar pago")').click();
    await expect(page.locator('.alert-success')).toBeVisible();
    await foto(page, 'secretaria-pago-aprobado');

    await page.goto('ReservaController?accion=listar');
    const tr = page.locator('tr', { hasText: PAC.apellido }).first();
    await expect(tr).toBeVisible();
    await foto(page, 'secretaria-solicitudes');
    await tr.locator('button[title*="Aprobar"]').click();
    await expect(page.locator('body')).toContainText('aprobada');
    await foto(page, 'secretaria-reserva-aprobada');
    await salir(page);
  });

  test('6. Paciente consulta "Mi reserva" y ve su boleta', async ({ page }) => {
    await page.goto('consultareserva.jsp');
    await page.fill('#codigo', codigoReserva);
    await page.fill('#dni', PAC.dni);
    await page.click('button[type="submit"]');
    await expect(page.locator('body')).toContainText('B001');
    await foto(page, 'paciente-boleta');
  });

  test('7. DNI repetido con otro nombre: aviso inmediato', async ({ page }) => {
    await page.goto('ServicioController?action=formreservaa');
    await page.fill('#nombre', 'Otro'); await page.fill('#apellido', 'Nombre Distinto');
    await page.fill('#dni', PAC.dni);
    await page.dispatchEvent('#dni', 'change');
    await expect(page.locator('#avisoDni')).toBeVisible();
    await expect(page.locator('#avisoDni')).toHaveClass(/alert-danger/);
    await foto(page, 'paciente-dni-repetido');
  });

  test('8. Seguridad: la secretaria no entra al panel del administrador', async ({ page }) => {
    await login(page, SEC.dni, SEC.clave);
    await page.goto('ADMPUsuarios.jsp');
    await expect(page.locator('body')).toContainText(/denegado/i);
    await foto(page, 'seguridad-acceso-denegado');
    await salir(page);
  });

  test('9. Odontólogo nuevo inicia sesión y ve su agenda', async ({ page }) => {
    await login(page, ODO.dni, 'Odonto2026');
    await expect(page).not.toHaveURL(/iniciosesion/);
    await foto(page, 'odontologo-agenda');
    await salir(page);
  });

  test('10. Asistente virtual responde solo temas de la clínica', async ({ page }) => {
    await page.goto('index.jsp');
    await page.click('#chatHeader');
    await page.fill('#pregunta', 'me duele la muela al tomar frío');
    await page.click('.chat-input button');
    await expect(page.locator('#chat-body')).toContainText(/endodoncia|caries|evaluación/i, { timeout: 20000 });
    await page.fill('#pregunta', 'cómo cocino arroz');
    await page.click('.chat-input button');
    await expect(page.locator('#chat-body')).toContainText(/salud bucal|dental/i, { timeout: 20000 });
    await foto(page, 'asistente-virtual');
  });
});
