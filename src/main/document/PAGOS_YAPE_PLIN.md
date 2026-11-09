# Yape / Plin: qué se puede hacer sin pasarela

## Situación real

Yape y Plin no ofrecen una API pública de cobro para que una web reciba pagos de
terceros. La integración automática (confirmar el abono sin intervención humana)
requiere un agregador de pagos o un convenio empresarial. Como el usuario pidió
eliminar la pasarela de proveedor, el sistema queda en **registro manual**.

## Opción implementada (recomendada para este alcance)

1. La clínica configura su titular y número de negocio reales:
   `pagos.titular`, `pagos.numero` y una carpeta privada `pagos.adjuntos.dir`.
2. El paciente paga desde su app Yape/Plin al número del negocio.
3. En «Mi reserva» adjunta la captura, código de operación, titular y DNI.
4. Secretaría verifica el movimiento y aprueba o rechaza con motivo.
5. Al aprobar se emite la boleta; el comprobante NO cuenta como pago antes de la
   revisión.

Los datos configurados para la demo son **`ART DENT SAC` / `986765235`**.
Siguen siendo datos de demostración: antes de un cobro real deben confirmarse con
el titular de la cuenta del negocio. No usar el número personal de un trabajador.

## Opciones adicionales sin pasarela

- **QR estático de Yape/Plin del negocio** impreso o en pantalla, junto al mismo
  formulario de comprobante. No confirma el pago automáticamente.
- **Validación en ventanilla**: el paciente paga en caja y secretaría registra el
  pago en efectivo; no requiere comprobante digital.
- **Conciliación manual diaria** contra el estado de cuenta del negocio, usando
  el código de operación como llave.

## Si más adelante se acepta un agregador

Un proveedor (Culqi, Mercado Pago, Izipay u otro) permitiría QR dinámico y
confirmación por webhook. Eso vuelve a introducir una pasarela y credenciales
externas; no se implementó porque contradice la decisión actual. No se debe
simular una confirmación automática: sin webhook firmado, el pago sigue siendo
manual.

## Configuración local

```properties
pagos.titular=ART DENT SAC
pagos.numero=986765235
pagos.adjuntos.dir=/ruta/absoluta/fuera-de-webapp/comprobantes
```

La carpeta debe existir, ser absoluta y estar fuera de `src/main/webapp`.
