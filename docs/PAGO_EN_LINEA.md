# Pago en línea (Mercado Pago, R-01)

## Qué quedó implementado

- `MercadoPagoService`: crea la preferencia de Checkout Pro y consulta el pago
  contra `GET /v1/payments/{id}` con el access token del servidor.
- `PagoEnLineaController` (`/PagoEnLinea`):
  - `POST accion=crear` — solo para una reserva de la propia sesión, con token de
    formulario y sin pago previo. Redirige al checkout de Mercado Pago.
  - `GET accion=retorno` — vuelve del checkout, verifica el pago en la API y
    registra Pago + boleta únicamente si el estado es `approved` y el importe
    coincide con el costo vigente del servicio.
  - `GET accion=notificacion` — webhook idempotente con la misma verificación.
- Botón «Pagar con tarjeta (Mercado Pago)» en `citareservada.jsp` y «Pagar S/ …
  en línea» en `WEB-INF/pagos-manuales.jsp`, visibles solo con `mp.enabled=true`.
- La reserva pasa a estado 3 (confirmada) al cobrarse y el pago queda con
  `MetodoPago=3` (Mercado Pago, R-01) y código `MP:<idPago>`, protegido por el
  índice único `CodigoTransaccion_UNIQUE` (una operación no se registra dos veces).

## Configuración (solo en `src/main/resources/config.properties`)

```properties
mp.enabled=true
mp.public.key=APP_USR-...        # credencial de prueba
mp.access.token=APP_USR-...      # nunca en el frontend ni en el repositorio
mp.base.url=http://localhost:8080/ArtDent
# mp.api.url=                    # opcional: solo para pruebas con un stub local
```

`config.properties` está excluido del WAR (`packagingExcludes`) y del build
(`<resources><excludes>`). `config.properties.example` solo lleva los nombres.

## Cómo probarlo en el navegador

1. `mvn -B jetty:run` y abrir
   `http://127.0.0.1:8080/ArtDent/PagoController?action=consultar&codigo=14&dni=41236587`.
2. Entrar a «Pagos Yape / Plin» de esa reserva y pulsar
   **Pagar S/ 40.00 en línea**.
3. En el checkout de Mercado Pago elegir **Tarjeta** y usar una tarjeta de
   prueba, por ejemplo Mastercard `5031 7557 3453 0604`, vencimiento `11/30`,
   CVV `123`, titular `APRO`, documento `123456789` (pago aprobado). Otros
   titulares generan otros resultados: `OTHE` rechazo, `CONT` pendiente, etc.
4. Al volver, la página muestra «Pago aprobado» con el código de reserva y el
   comprobante interno; la boleta queda disponible y la cita pasa a confirmada.

**Requisito de Mercado Pago:** `back_urls` y `auto_return` solo se aceptan con
**HTTPS**. En local (`http://localhost`) el sistema omite esos campos y Mercado
Pago no devuelve al sitio automáticamente: hay que abrir el retorno a mano con
`/PagoEnLinea?accion=retorno&payment_id=<id>`. En un dominio con HTTPS la vuelta
es automática y el webhook `accion=notificacion` funciona sin intervención.

## Verificación ya realizada

- Preferencia real creada con las credenciales de prueba → `302` a
  `https://www.mercadopago.com.pe/checkout/v1/redirect?pref_id=…`; el checkout
  muestra el servicio y S/ 40.
- Retorno con pago aprobado (respuesta equivalente de la API): Pago `MP:777`,
  boleta `B001-00000011`, cita a estado 3; repetir el retorno responde «La
  reserva ya tenía un pago registrado» sin duplicar.
- Sin `payment_id` y con pago desconocido se muestra el aviso correspondiente sin
  registrar nada.
- Completa el pago con la cuenta de prueba de comprador desde el navegador: la
  verificación de Mercado Pago (contraseña/reCAPTCHA) impide automatizarlo aquí.

## Probar en Railway (sandbox)

En un dominio con HTTPS la vuelta desde el checkout y el webhook funcionan sin
intervención. Configura en el servicio JSP (ver `docs/DESPLIEGUE_RAILWAY.md`):

```properties
ARTDENT_MP_ENABLED=true
ARTDENT_MP_BASE_URL=https://<tu-dominio>.up.railway.app   # sin barra final
ARTDENT_MP_ACCESS_TOKEN=TEST-...                          # credenciales de prueba
ARTDENT_MP_PUBLIC_KEY=TEST-...
```

`ARTDENT_MP_BASE_URL` es obligatorio detrás del proxy: si falta, la app deduce
`http://` y Mercado Pago ignora `back_urls`, `auto_return` y `notification_url`.

### Preparar la cuenta de prueba

1. Mercado Pago Developers → **Tus integraciones** → tu aplicación.
2. **Credenciales de prueba**: copia el *Access Token* (`TEST-…`). La aplicación
   crea automáticamente una cuenta de prueba (hasta 15 por cuenta).
3. Si el checkout pide iniciar sesión, usa la cuenta de prueba **comprador** que
   aparece en la misma pantalla (y su código de 6 dígitos si lo solicita).

### Tarjetas de prueba (Perú)

| Tarjeta | Número | CVV | Vence | Titular | Documento | Resultado |
|---|---|---|---|---|---|---|
| Mastercard | `5031 7557 3453 0604` | `123` | `11/30` | `APRO` | `123456789` | aprobado |
| Mastercard | `5031 7557 3453 0604` | `123` | `11/30` | `OTHE` | `123456789` | rechazado |
| Mastercard | `5031 7557 3453 0604` | `123` | `11/30` | `CONT` | — | pendiente |
| Visa | `4009 1753 3280 6176` | `123` | `11/30` | `APRO` | `123456789` | aprobado |

El nombre del titular decide el escenario; el número puede ser el mismo.

### Guion de prueba en el navegador

1. Portal público → reservar un servicio (queda `ART-RES-000NN`, estado 1).
2. En la pantalla de reserva, pulsar **Pagar con tarjeta (Mercado Pago)**.
3. En el checkout, tarjeta de prueba con titular `APRO`.
4. Vuelve solo a `/PagoEnLinea?accion=retorno`: debe mostrar «Pago aprobado»,
   código de boleta `B001-…` y la cita en estado confirmada.
5. «Mi reserva» (código + DNI) debe mostrar el pago y el comprobante.

### Casos que conviene demostrar

| Caso | Cómo | Resultado esperado |
|---|---|---|
| Aprobado | tarjeta APRO | 1 fila en `Pago` (`MP:<id>`, método 3), 1 boleta, cita estado 3 |
| Rechazado | tarjeta OTHE | sin `Pago` ni boleta, mensaje de rechazo, cita sin cambios |
| Pendiente | tarjeta CONT | mensaje «procesando», sin pago registrado |
| Doble notificación | abrir dos veces `GET /PagoEnLinea?accion=notificacion&data.id=<id>` | responde `ok`, un solo `Pago` (idempotente) |
| Importe alterado | modificar el `costo` en la BD antes del retorno, o el `unit_price` enviado | se rechaza: el importe se compara contra el costo vigente |
| Sin sesión de reserva | `POST accion=crear` con otra cita | `403` (solo reservas de la propia sesión) |

### Probar el webhook sin esperar a Mercado Pago

```bash
# 1. Paga en el checkout y anota el payment_id del retorno.
# 2. Simula la notificación:
curl -i "https://<tu-dominio>/PagoEnLinea?accion=notificacion&data.id=<payment_id>"
# 3. El endpoint responde 200 "ok" y registra el pago solo si la API lo confirma.
```

En la pantalla **Eventos y alertas** deben aparecer los `INFO` «Preferencia de
pago en línea creada» y «Pago en línea aprobado», y los `ADVERTENCIA` si el
proveedor no responde o el importe no coincide.

> El webhook no valida la firma `x-signature` de Mercado Pago: la seguridad se
> basa en consultar el pago contra la API con el token del servidor y comparar
> importe y referencia. Si se publica con cobros reales, conviene añadir la
> validación de firma.
