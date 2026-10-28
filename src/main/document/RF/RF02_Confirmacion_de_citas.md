# Guía de Usuario y Documentación Funcional: RF02 - Confirmación de Citas

---

## 1. Ficha del Requerimiento

| Campo | Detalle |
| :--- | :--- |
| **Identificador** | **RF02** |
| **Nombre del Requerimiento** | Confirmación de citas |
| **Prioridad** | Media |
| **Módulo** | Citas y Reservas Web / Emisión de Comprobantes |
| **Cambio en APF2** | **Modificado:** Se incorpora la generación y visualización obligatoria del **Código Único de Reserva** (formato oficial `ART-RES-XXXXX`), visible inmediatamente tras completar la reservación web. |

---

## 2. Descripción en Lenguaje Sencillo

Una vez que el paciente completa su reserva (sin necesidad de iniciar sesión, conforme a RF01), el sistema calcula y le asigna un **Código Único de Reserva** institucional (por ejemplo: `ART-RES-00007`). 

Este código cumple las siguientes funciones:
1. **Identificador Rápido:** Permite al paciente presentarse en la recepción física de la clínica o llamar por teléfono indicando únicamente su código para ser ubicado de inmediato en el sistema.
2. **Seguimiento del Estado:** El comprobante emitido muestra que la cita está **"En espera"**, con el detalle del servicio, el odontólogo y el horario acordado.
3. **Impresión y Digitalización:** El paciente puede guardar el código en su móvil o imprimir directamente el voucher para presentarlo el día de su cita dental.

---

## 3. Proceso Paso a Paso para el Usuario

### Paso 1: Completar la reserva web
1. Ingresar al formulario de reserva web:  
   `http://localhost:8080/ArtDent/ServicioController?action=formreservaa`
2. Completar los campos requeridos:
   * DNI, Nombres, Apellidos, Celular y Correo.
   * Servicio seleccionado (ej. *Blanqueamiento Dental*).
   * Fecha de atención y hora deseada.
   * Odontólogo asignado (ej. *Dr. Rubén Cuadros*).
3. Hacer clic en **"Confirmar Reserva"**.

### Paso 2: Visualización del Código de Reserva
Al confirmarse el registro, el sistema redirige automáticamente a la pantalla de comprobante (`citareservada.jsp`), donde se observa:
* Un recuadro superior destacado en azul:  
  **`Código Único de Reserva (RF02): ART-RES-00007`**
* El distintivo en amarillo con el estado **"En espera"**.
* El detalle del paciente y del turno médico asignado.
* Las opciones para **"Imprimir Voucher"** o **"Reservar otra cita"**.

---

## 4. Auditoría Técnica y Base de Datos

El código de reserva está vinculado biunívocamente al identificador físico de la cita en MySQL:

```sql
SELECT c.idCita, CONCAT('ART-RES-', LPAD(c.idCita, 5, '0')) AS CodigoReserva, 
       c.FechaCita, c.HoraCita, c.Origen, e.TipoEstado, p.Nombre, p.Apellido
FROM Cita c
INNER JOIN Estado e ON c.Estado_idEstado = e.idEstado
INNER JOIN Paciente p ON c.Paciente_idPaciente = p.idPaciente
WHERE c.idCita = 7;
```

* **Resultado verificado:**
  * `idCita` = `7`
  * `CodigoReserva` = `'ART-RES-00007'`
  * `Origen` = `'Web'`
  * `TipoEstado` = `'En espera'`
  * `total_pagos` = `0` (Desacoplado de cobro según APF2).

---

## 5. Prueba Automatizada

La verificación del código de reserva forma parte de la suite E2E. Puede ejecutarse con:
```bash
python3 test_rf01_e2e.py
```
El test valida que la respuesta HTTP contenga el formato regex `ART-RES-\d{5}` y coincida con el registro persistido en la base de datos.
