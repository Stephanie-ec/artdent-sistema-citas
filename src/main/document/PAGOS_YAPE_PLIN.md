# Yape / Plin: qué se puede hacer sin pasarela

## Situación real

Yape y Plin no ofrecen una API pública de cobro para que una web reciba pagos de
terceros. La integración automática (confirmar el abono sin intervención humana)
requiere un agregador de pagos o un convenio empresarial. Como el usuario pidió
eliminar la pasarela de proveedor, el sistema queda en **registro manual**.

## Opción implementada (recomendada para este alcance)

1. La clínica configura su titular y número de negocio reales:
   `pagos.titular`, `pagos.numero` y una carpeta privada `pagos.adjuntos.dir`
   (relativa a `datos.dir`; por defecto `<usuario>/artdent`).
2. El paciente paga desde su app Yape/Plin al número del negocio.
3. En «Mi reserva» adjunta la captura, código de operación, titular y DNI.
4. Secretaría verifica el movimiento y aprueba o rechaza con motivo.
5. Al aprobar se emite la boleta; el comprobante NO cuenta como pago antes de la
   revisión.

Los datos configurados para la demo son **`ART DENT S.A.C.` / `987654321`** (móvil que figura en el comprobante).
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

Mercado Pago ya está integrado como **Checkout Pro** (R-01, ver
`docs/PAGO_EN_LINEA.md`): el paciente puede pagar con tarjeta y el pago se
confirma consultando la API, sin revisión humana. El flujo manual de Yape/Plin
con comprobante se mantiene para quien no pague en línea. Cualquier otro
agregador introduciría una pasarela adicional y no está implementado.

## Configuración local

```properties
pagos.titular=ART DENT SAC
pagos.numero=986765235
# Relativa a datos.dir (por defecto <usuario>/artdent); nunca dentro del sitio público.
datos.dir=
pagos.adjuntos.dir=comprobantes-pagos
```

La carpeta debe existir, ser absoluta y estar fuera de `src/main/webapp`.
