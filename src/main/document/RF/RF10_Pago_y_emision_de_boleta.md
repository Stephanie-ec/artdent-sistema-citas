# RF10 — Pago y emisión de boleta

Alcance vigente: Yape/Plin con verificación manual por secretaría o administrador,
por el importe completo del tratamiento; efectivo en ventanilla permanece disponible.
El antiguo formulario de tarjeta fue retirado; el endpoint de simulación está
inhabilitado por defecto y requiere habilitación explícita de laboratorio.

## Paciente

Después de reservar, o desde Mi reserva consultada con código y DNI, el paciente
abre «Enviar comprobante Yape/Plin». Ve el titular y número configurados por la clínica,
y envía canal, código de operación, imagen y datos del titular de la boleta.
Solo se admiten JPEG/PNG de hasta 5 MB y 12 megapíxeles; la imagen se vuelve a
codificar y se guarda fuera del sitio público. El importe se obtiene del servidor.
Sin configuración de la cuenta y almacenamiento, el canal permanece deshabilitado.

Una solicitud PENDIENTE no crea Pago ni Comprobante y no confirma la cita. El
paciente consulta el estado y, si se rechaza, el motivo y la opción de reenviar.
Los comprobantes adjuntos solo están disponibles al paciente autorizado para esa
reserva o al personal de administración/secretaría. No hay URL pública al archivo.

## Revisión, boleta y devolución

El personal verifica canal, código, titular e importe en la cuenta bancaria y confirma
esa revisión. La aprobación registra Pago y Comprobante y confirma una reserva Web
pendiente en una sola transacción. Cada operación aprobada es única por canal/código;
cada cita tiene como máximo un pago y cada pago una boleta con correlativo B001.
Doble clic, dos revisores o carrera con efectivo no deben duplicar pago o boleta.
Una revisión desde una pantalla antigua no puede invertir el resultado ya guardado.
El rechazo del comprobante conserva la cita pendiente; no equivale a rechazar la cita.

Las citas canceladas/rechazadas no admiten aprobación ni cobros nuevos. Cancelar una
pagada conserva Pago/Comprobante y crea una devolución PENDIENTE. El personal registra
la devolución manual completa con referencia, fecha y actor; el paciente ve REALIZADA.
El sistema registra esa gestión: no realiza transferencias ni devoluciones bancarias.

El registro en efectivo conserva el flujo clínico existente: después de cobrar una
reserva Web pendiente, el personal debe aprobar la reserva. El importe no se acepta
del formulario. La boleta es el comprobante generado por la aplicación; esta entrega
no incluye una integración con SUNAT ni acredita validación tributaria externa.

## Verificación

`PagosIT`, `EstadosIT`, `CierrePendientesIT`, `CierreAccesoTest` y
`CierreServiciosTest` cubren transacciones, autorización y archivos. La aceptación
visual y la verificación bancaria real siguen pendientes. Probar únicamente con
cuentas y movimientos autorizados; no confundir una imagen ficticia con pago real.