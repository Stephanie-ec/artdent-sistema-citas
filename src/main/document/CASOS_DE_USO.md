# Casos de uso — cierre de pendientes

```mermaid
flowchart LR
    Paciente[Paciente / visitante] --> Reservar([Reservar cita])
    Paciente --> Consultar([Consultar mi reserva])
    Paciente --> Comprobante([Enviar comprobante Yape / Plin])
    Paciente --> Boleta([Consultar boleta y devolución])
    Paciente --> Asistente([Consultar asistente dental])
    Secretaria[Secretaría] --> Agenda([Gestionar agenda y solicitudes])
    Secretaria --> Validar([Verificar pago / registrar efectivo])
    Secretaria --> Devolver([Registrar devolución manual])
    Secretaria --> Avisos([Consultar y reintentar correos])
    Administrador[Administrador] --> Personal([Gestionar personal y servicios])
    Administrador --> Reportes([Consultar reportes])
    Administrador --> Ficha([Registrar / consultar ficha y finalizar atención])
    Administrador -. incluye funciones de .-> Secretaria
    Odontologo[Odontólogo titular] --> AgendaPropia([Consultar agenda propia])
    Odontologo --> Ficha
```

El odontólogo registra y consulta únicamente fichas de sus citas. El administrador
puede hacerlo para cualquier cita. Secretaría no registra ni consulta el contenido
clínico de la nueva ficha. El paciente accede a su reserva con código y DNI; esa
autorización de sesión limita sus comprobantes y devoluciones. La administración
abarca las funciones de secretaría sin requerir otra cuenta.
