# Guía de Usuario y Documentación Funcional: RF10 - Pago y Emisión de Boleta Electrónica

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF10** |
| **Nombre del Requerimiento** | Pago y Emisión de Boleta |
| **Prioridad** | **Alta** |
| **Módulo** | Módulo de Facturación, Caja y Pasarela de Pagos |
| **Roles Autorizados** | **Paciente** (Pago en línea mediante pasarela web), **Secretaria** (Registro de cobro en ventanilla en efectivo), **Administrador** (Supervisión de comprobantes e ingresos) |
| **Cambio en APF2** | **Modificado:** Dos medios de pago autorizados (En línea y Efectivo); registro transaccional en tabla `Pago` y emisión obligatoria de **Boleta Electrónica** (tabla `Comprobante`) con serie `B001` y número correlativo de 8 dígitos a nombre de quien paga (por defecto, el paciente). **El sistema no emite facturas** por política institucional y tributaria dental. |

---

## 2. Descripción en Lenguaje Sencillo

Este requerimiento formaliza la cobranza de las atenciones odontológicas, asegurando la transparencia tributaria y contable del Centro Odontológico ArtDent:

1. **Dos Medios de Pago Habilitados:**
   * **En Línea (Paciente):** Tras realizar una reserva web (RF01/RF02), el paciente puede pagar inmediatamente desde el comprobante de reserva mediante la pasarela segura simulada (tarjeta Visa/Mastercard).
   * **Efectivo en Ventanilla (Secretaria):** Cuando el paciente acude físicamente al centro o se registra una cita presencial, la Secretaria recibe el dinero en efectivo y registra el cobro directamente en el sistema con un solo clic.
2. **Emisión Automática de Boleta Electrónica:**
   * Cada pago exitoso genera un comprobante oficial de tipo **Boleta de Venta Electrónica** con serie fija **`B001`** y correlativo numérico de 8 dígitos (ejemplo: `B001-00000004`).
   * La boleta se expide a nombre del paciente o del pagador titular con su respectivo DNI.
   * El sistema calcula de manera automática la desagregación de la Operación Gravada y el 18% del I.G.V.
3. **No Emisión de Facturas:**
   * Por definición estricta del cliente y requerimientos del negocio, el sistema no emite facturas con RUC de personas jurídicas; todas las atenciones odontológicas emiten boleta electrónica a personas naturales.
4. **Vínculo Transaccional Seguro:**
   * Cada cita/reserva cuenta con un control de unicidad (`Cita_UNIQUE` en tabla `Pago` y `Pago_UNIQUE` en tabla `Comprobante`), impidiendo cobros duplicados o comprobantes huérfanos.

---

## 3. Proceso Paso a Paso para el Usuario

### Flujo 1: Paciente - Pago en Línea desde la Web

1. **Realizar Reserva Web:**
   * Completar la reserva en la página de inicio o formulario de reservas.
2. **Visualizar Voucher y Botón de Pago:**
   * En la pantalla de confirmación (`citareservada.jsp`), observar el bloque de costo del servicio y presionar el botón verde **"Pagar en Línea Ahora (RF10)"**.
3. **Ingresar Datos en la Pasarela Segura:**
   * Se abrirá la ventana modal de pago seguro de ArtDent.
   * El sistema precarga el nombre y DNI del paciente, así como el monto exacto del servicio (ej. `S/ 100.00`).
   * Ingresar o verificar los datos de la tarjeta de crédito o débito, fecha de caducidad y código CVV.
4. **Confirmar Transacción:**
   * Presionar el botón **"Confirmar Pago"**.
   * El sistema procesa la transacción de forma inmediata (generando un código transaccional único `TXN-...`), inserta el registro en la tabla `Pago` (método 1: En línea), crea la boleta correlativa en `Comprobante` (serie `B001`) y redirige automáticamente a la vista oficial de la boleta.
5. **Imprimir o Guardar Boleta:**
   * En la pantalla de la boleta electrónica (`boleta.jsp`), el paciente puede presionar **"Imprimir Boleta"** para obtener su documento físico o guardarlo en formato PDF.

---

### Flujo 2: Secretaría - Registro de Cobro en Efectivo en Ventanilla

1. **Iniciar Sesión:**
   * Acceder con credenciales de Secretaría (`78223344` / `1234`).
2. **Ir a Solicitudes de Reserva o Citas:**
   * En el menú lateral, seleccionar **"Solicitudes"** (`PDCSolicitudes.jsp`).
3. **Identificar la Cita Pendiente de Pago:**
   * En la columna **"Pago / Boleta (RF10)"**, las citas no pagadas muestran una insignia amarilla: `[⌛ Pendiente]` acompañada del botón verde **"Cobrar"**.
4. **Abrir Modal de Cobro en Efectivo:**
   * Presionar el botón **"Cobrar"** en la fila del paciente respectivo.
   * Se despliega el formulario modal **"Registrar Pago en Efectivo (RF10)"**.
5. **Completar y Confirmar Cobro:**
   * Verificar el nombre del paciente y su DNI.
   * Validar el monto del servicio recibido en efectivo.
   * Presionar **"Confirmar Cobro"**.
6. **Resultado Inmediato:**
   * El sistema genera una transacción con identificador de caja `EFEC-YYYYMMDDHHMMSS`, inserta el pago con método 2 (Efectivo) y genera la boleta correlativa `B001-XXXX`.
   * La tabla se actualiza mostrando la insignia verde `[✓ Pagado]`, el número oficial de boleta (ej. `B001-00000003`) y un botón para visualizar o reimprimir el comprobante en cualquier momento.

---

## 4. Reglas de Negocio e Integridad Técnica

1. **Correlatividad Estricta de Boletas:**
   * La serie siempre es `B001`.
   * El número es un correlativo autoincremental por serie con relleno de ceros a la izquierda a 8 posiciones (`LPAD(..., 8, '0')`).
2. **Atribución de Medios de Pago (`MetodoPago`):**
   * ID `1`: `En línea` (Pasarela de pagos web).
   * ID `2`: `Efectivo` (Caja en recepción del centro).
3. **Consistencia Transaccional ACID:**
   * El método `PagoDaoImpl.registrarPagoYComprobante` utiliza transacciones JDBC con `conn.setAutoCommit(false)`, `commit()` y `rollback()`, garantizando que jamás se registre un pago sin su boleta correspondiente.
4. **Control de Duplicidad:**
   * La base de datos contiene índices únicos que impiden registrar dos pagos para una misma cita (`Cita_idCita UNIQUE`).

---

## 5. Evidencias de Validación y Auditoría

### 5.1 Verificación en Base de Datos MySQL (`db_artdent_apf2`)

```sql
-- Verificar pagos registrados
SELECT idPago, Monto, FechaPago, CodigoTransaccion, MetodoPago_idMetodo, Cita_idCita 
FROM Pago ORDER BY idPago DESC LIMIT 3;

-- Verificar comprobantes correlativos generados
SELECT idComprobante, Serie, Numero, FechaEmision, NombreCliente, DNICliente, Pago_idPago 
FROM Comprobante ORDER BY idComprobante DESC LIMIT 3;
```

**Resultado obtenido en pruebas:**
* `idPago = 3`: Monto `100.00`, Código `EFEC-...`, Método `2` (Efectivo), Cita `12`.
* `idComprobante = 3`: Serie `B001`, Número `00000003`, Cliente `Valeria Torres`, DNI `73445566`.
* `idPago = 4`: Monto `100.00`, Código `TXN-...`, Método `1` (En línea), Cita `14`.
* `idComprobante = 4`: Serie `B001`, Número `00000004`, Cliente `Camila Silva`, DNI `75667788`.

### 5.2 Verificación Visual en Google Chrome

* **Boleta Electrónica (`boleta_electronica_ui.png`):** Muestra el formato estándar oficial con membrete de ArtDent, RUC, detalle del servicio, impuestos y pie normativo (no facturas).
* **Pasarela de Pagos (`pasarela_modal_ui.png`):** Modal interactivo con validación de tarjeta y confirmación segura de la operación.
