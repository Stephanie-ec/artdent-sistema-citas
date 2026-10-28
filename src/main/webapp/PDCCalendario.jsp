<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="pe.edu.utp.entity.VerReserva"%>
<%@ page import="java.util.Map" %>
<%@ page import="pe.edu.utp.components.DiasNumericosDeLaSemana" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter, java.util.Locale" %>
<%@ page import="java.time.temporal.WeekFields" %>
<%
    Integer semanaActual = (Integer) request.getAttribute("semanaActual");
    if (semanaActual == null) {
        semanaActual = (Integer) request.getSession().getAttribute("semanaActual");
    }
    if (semanaActual == null) {
        semanaActual = LocalDate.now().get(WeekFields.ISO.weekOfYear());
    }
    LocalDate inicioSemana = LocalDate.now()
            .with(WeekFields.ISO.weekOfYear(), semanaActual)
            .with(WeekFields.ISO.dayOfWeek(), 1); // Lunes
    LocalDate finSemana = inicioSemana.plusDays(6); // Domingo
    Locale localeEspanol = new Locale("es", "ES");
    DateTimeFormatter formatoMes = DateTimeFormatter.ofPattern("MMMM", localeEspanol);

    String mesInicio = inicioSemana.format(formatoMes);
    mesInicio = mesInicio.substring(0, 1).toUpperCase() + mesInicio.substring(1);

    String mesFin = finSemana.format(formatoMes);
    mesFin = mesFin.substring(0, 1).toUpperCase() + mesFin.substring(1);

    String rangoTexto = "Del " + inicioSemana.getDayOfMonth() + " de " + mesInicio + " al " + finSemana.getDayOfMonth() + " de " + mesFin + " de " + finSemana.getYear();
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Panel de Control - Clínica</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.5/font/bootstrap-icons.min.css">
        <link rel="stylesheet" href="css/style.css">
        <style>
            /* Estilos CSS */
            .calendar-wrap {
                container: calendar;
            }

            .calendar {
                --dayHeaderHeight: 75px;
                --hourHeight: 58px;

                display: flex;

                .hours {
                    > ol > li:first-of-type {
                        margin-block-start: var(--dayHeaderHeight);
                    }
                    > ol > li {
                        block-size: var(--hourHeight);
                    }
                    white-space: nowrap;
                    border-inline-end: 1px solid var(--gray);
                    .day-time {
                        padding-block: 0.25rem;
                        padding-inline-end: 0.5rem;
                        border-block-start: 1px solid var(--gray);
                    }
                }

                .days {
                    width: 100%;
                }

                .day-number {
                    font-weight: 300;
                    font-size: 2rem;
                }
                .day-name {
                    text-transform: uppercase;
                    font-weight: 500;
                }

                .events {
                    display: flex;
                    width: 100%;

                    .day-of-events {
                        flex: 1;
                        padding-inline: 0.75rem;
                        display: grid;
                        grid-template-rows: var(--dayHeaderHeight) repeat(60, calc(var(--hourHeight) / 4));
                        grid-template-columns: 1fr;
                        border-inline-end: 1px solid var(--gray);

                        & dt {
                            grid-row: 1;
                        }
                    }

                    .event {
                        --gray: rgba(0,0,0,0.08);
                        grid-row: var(--row) / span var(--span, 4);
                        border: 1px solid var(--gray);
                        border-radius: 6px;
                        padding: 0.25rem 0.45rem;
                        box-shadow: 0 2px 4px rgba(0,0,0,0.12);
                        overflow: hidden;
                        display: flex;
                        flex-direction: column;
                        justify-content: space-between;
                        transition: transform 0.15s ease, box-shadow 0.15s ease;
                    }
                    .event:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 4px 8px rgba(0,0,0,0.22);
                    }
                }
            }

            /* Container Queries */
            @container calendar (max-width: 690px) {
                .calendar {
                    display: block;
                }
                .hours {
                    display: none;
                }
                .events {
                    display: block;

                    .day-of-events {
                        border: 0;
                        grid-template-columns: 75px 1fr;
                        grid-template-rows: auto;
                        gap: 0.75rem;
                        margin-block-end: 2rem;
                        .event {
                            grid-column: 2;
                            grid-row: auto;
                        }
                    }
                }
            }

            @container calendar (max-width: 350px) {
                .events {
                    .day-of-events {
                        display: block;
                        .event {
                            margin-block-end: 0.25rem;
                        }
                        & dt {
                            display: flex;
                            margin-block-end: 0.25rem;

                            .day-number {
                                font-size: 1.2rem;
                                font-weight: 800;
                                margin-inline-end: 0.25rem;
                            }
                            .day-name {
                                font-size: 1.2rem;
                            }
                        }
                    }
                }
            }

            .info-panel {
                padding: 1rem 2rem;
                container: InfoPanel / inline-size;

                & h1 {
                    font-size: max(7cqi, 24px);
                }
            }

            split-panel {
                background: white;
                padding: 1rem 0.5rem;
            }

            @layer reset {
                * {
                    box-sizing: border-box;
                }
                ol,
                ul,
                dl {
                    list-style: none;
                    padding: 0;
                    margin: 0;
                }
                dd {
                    margin: 0;
                }
                h1 {
                    line-height: 1.1;
                }
            }
        </style>
    </head>
    <body class="d-flex flex-column min-vh-100">
        <%@include file="NavPanel.jsp" %>

        <div class="d-flex flex-grow-1">
            <%@include file="Sidebar.jsp" %>

            <div class="content container-fluid p-4">
                <%
                    String rolCal = (session.getAttribute("TipoRol") != null) ? session.getAttribute("TipoRol").toString() : "";
                    String docNom = (session.getAttribute("Nombre") != null) ? session.getAttribute("Nombre").toString() : "";
                    String docApe = (session.getAttribute("Apellido") != null) ? session.getAttribute("Apellido").toString() : "";
                    boolean esDocCal = rolCal.equalsIgnoreCase("Odontologo");
                %>
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <div>
                        <h3 class="mb-1 fw-bold text-brand-primary">
                            <%= esDocCal ? "Agenda Semanal Personalizada" : "Calendario General de Citas" %>
                        </h3>
                        <% if (esDocCal) { %>
                            <span class="badge bg-mint text-dark px-3 py-2 fs-6">
                                <i class="bi bi-person-badge-fill text-brand-primary me-1"></i>Dr(a). <%= docNom %> <%= docApe %> &bull; Odontología
                            </span>
                            <span class="text-secondary ms-2 small">Visualizando exclusivamente las citas y pacientes asignados a su agenda médica.</span>
                        <% } else { %>
                            <span class="text-secondary small">Visualización integral de citas presenciales y reservas web del centro odontológico.</span>
                        <% } %>
                    </div>
                </div>
                <% if ("completadoOk".equals(request.getParameter("msg"))) { %>
                    <div class="alert alert-success alert-dismissible fade show mb-3" role="alert">
                        <i class="bi bi-check-circle-fill me-2"></i><strong>¡Atención Finalizada!</strong> La cita ha sido marcada como <strong>Completada</strong> con éxito.
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <% } %>
                <div class="calendar-controls d-flex justify-content-between align-items-center pb-4 pt-2">
                    <div>
                        <span class="fs-5 fw-bold text-primary">Semana <%= semanaActual%></span><br>
                        <span class="text-muted"><%= rangoTexto%></span>
                    </div>
                    <div class="d-flex align-items-center">
                        <a class="btn btn-outline-primary me-2" href="ReservaController?accion=hoy">Hoy</a>
                        <a class="btn btn-primary me-1" href="ReservaController?accion=semanaAnterior"><i class="bi bi-arrow-left"></i></a>
                        <a class="btn btn-primary" href="ReservaController?accion=semanaSiguiente"><i class="bi bi-arrow-right"></i></a>

                    </div>
                </div>

                <div class="calendar-wrap">
                    <div class="calendar">
                        <div class="hours">
                            <ol>
                                <li><div class="day-time">8 a.m.</div></li>
                                <li><div class="day-time">9 a.m.</div></li>
                                <li><div class="day-time">10 a.m.</div></li>
                                <li><div class="day-time">11 a.m.</div></li>
                                <li><div class="day-time">12 p.m.</div></li>
                                <li><div class="day-time">1 p.m.</div></li>
                                <li><div class="day-time">2 p.m.</div></li>
                                <li><div class="day-time">3 p.m.</div></li>
                                <li><div class="day-time">4 p.m.</div></li>
                                <li><div class="day-time">5 p.m.</div></li>
                                <li><div class="day-time">6 p.m.</div></li>
                                <li><div class="day-time">7 p.m.</div></li>
                                <li><div class="day-time">8 p.m.</div></li>
                                <li><div class="day-time">9 p.m.</div></li>
                                <li><div class="day-time">10 p.m.</div></li>
                            </ol>
                        </div>
                        <dl class="events">
                            <%
                                try {
                                    DiasNumericosDeLaSemana dias = new DiasNumericosDeLaSemana();

                                    Map<Integer, Integer> diasNumericos = dias.obtenerDiasNumericosDeEstaSemana(inicioSemana);
                                    int contador = 1;
                            %>



                            <c:set var="nombresDias" value="Lunes,Martes,Miércoles,Jueves,Viernes,Sábado,Domingo" />
                            <c:forEach var="dia" items="${fn:split(nombresDias, ',')}" varStatus="status">
                                <div class="day-of-events" data-day="${dia}">
                                    <dt>
                                        <div class="day-number">
                                            <%= diasNumericos.get(contador)%>
                                        </div>
                                        <div class="day-name">${dia}</div>
                                    </dt>

                                    <!-- Mostrar Reservas -->
                                    <c:if test="${not empty reservasPorDia[dia]}">
                                        <c:forEach var="reserva" items="${reservasPorDia[dia]}">
                                            <c:set var="horaReserva" value="${reserva.horaReserva}" />
                                            <c:set var="row" value="${reserva.orden_row}" />
                                            <c:set var="color" value="${reserva.color}" />
                                            <dd class="event reserva-event" style="--row: ${row}; --span: 5; background-color: ${color}; color: white; cursor: pointer;"
                                                data-bs-toggle="modal" data-bs-target="#reservaModal"
                                                data-id="${reserva.idReserva}"
                                                data-tipo="reserva"
                                                data-hora="${horaReserva}"
                                                data-servicio="${reserva.tipoServicio}"
                                                data-paciente="${reserva.nombrePaciente} ${reserva.apellidoPaciente}"
                                                data-odontologo="${reserva.nombreUsuario} ${reserva.apellidoUsuario}"
                                                data-estado="${reserva.estado}"
                                                data-importe="${reserva.importe}"
                                                data-descripcion="${reserva.descripcion}">
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <time class="fw-bold" style="font-size: 0.75rem;"><i class="bi bi-clock me-1"></i>${fn:substring(horaReserva, 0, 5)}</time>
                                                    <span class="badge bg-white text-dark py-0 px-1" style="font-size: 0.62rem; font-weight: 600;">Web</span>
                                                </div>
                                                <div class="event-title fw-bold text-truncate" style="font-size: 0.82rem; line-height: 1.2;">${reserva.tipoServicio}</div>
                                                <div class="text-truncate opacity-90 mt-1" style="font-size: 0.72rem;"><i class="bi bi-person-fill me-1"></i>${reserva.nombrePaciente} ${reserva.apellidoPaciente}</div>
                                            </dd>
                                        </c:forEach>
                                    </c:if>

                                    <!-- Mostrar Citas -->
                                    <c:if test="${not empty citasPorDia[dia]}">
                                        <c:forEach var="cita" items="${citasPorDia[dia]}">
                                            <c:set var="horaCita" value="${cita.horaReserva}" />
                                            <c:set var="row" value="${cita.orden_row}" />
                                            <c:set var="color" value="${cita.color}" />
                                            <dd class="event cita-event" style="--row: ${row}; --span: 5; background-color: ${color}; color: white; cursor: pointer;"
                                                data-bs-toggle="modal" data-bs-target="#citaModal"
                                                data-id="${cita.idCita}"
                                                data-tipo="cita"
                                                data-hora="${horaCita}"
                                                data-servicio="${cita.tipoServicio}"
                                                data-paciente="${cita.nombrePaciente} ${cita.apellidoPaciente}"
                                                data-odontologo="${cita.nombreUsuario} ${cita.apellidoUsuario}"
                                                data-estado="${cita.estado}"
                                                data-costo="${cita.costo}">
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <time class="fw-bold" style="font-size: 0.75rem;"><i class="bi bi-clock me-1"></i>${fn:substring(horaCita, 0, 5)}</time>
                                                    <span class="badge bg-white text-dark py-0 px-1" style="font-size: 0.62rem; font-weight: 600;">Presencial</span>
                                                </div>
                                                <div class="event-title fw-bold text-truncate" style="font-size: 0.82rem; line-height: 1.2;">${cita.tipoServicio}</div>
                                                <div class="text-truncate opacity-90 mt-1" style="font-size: 0.72rem;"><i class="bi bi-person-fill me-1"></i>${cita.nombrePaciente} ${cita.apellidoPaciente}</div>
                                            </dd>
                                        </c:forEach>
                                    </c:if>

                                </div>
                                <%
                                    contador++; // Incrementar el contador para el siguiente día
                                %>
                            </c:forEach>

                            <%
                                } catch (Exception e) {
                                    out.println("Error: " + e.getMessage());
                                }
                            %>
                        </dl>
                    </div>
                </div>
                <!-- Modal para Reservas -->
                <div class="modal fade" id="reservaModal" tabindex="-1" aria-labelledby="reservaModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="reservaModalLabel">Detalles de la Reserva</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <p><strong>ID:</strong> <span id="reservaId"></span></p>
                                <p><strong>Hora:</strong> <span id="reservaHora"></span></p>
                                <p><strong>Servicio:</strong> <span id="reservaServicio"></span></p>
                                <p><strong>Paciente:</strong> <span id="reservaPaciente"></span></p>
                                <p><strong>Odontólogo:</strong> <span id="reservaOdontologo"></span></p>
                                <p><strong>Estado:</strong> <span id="reservaEstado"></span></p>
                                <p><strong>Importe:</strong> <span id="reservaImporte"></span></p>
                                <p><strong>Descripción:</strong> <span id="reservaDescripcion"></span></p>
                            </div>
                            <div class="modal-footer d-flex justify-content-between">
                                <form id="formCompletarReserva" action="ReprogramacionController" method="post" style="display: none; margin: 0;">
                                    <input type="hidden" name="idReserva" id="btnIdReserva" value="" />
                                    <input type="hidden" name="estado" id="btnEstadoReserva" value="Confirmado" />
                                    <input type="hidden" name="accion" value="updateEstadoCompletado" />
                                    <button class="btn btn-success fw-bold" type="submit">
                                        <i class="bi bi-check2-circle me-1"></i>Finalizar Atención (Marcar Completado)
                                    </button>
                                </form>
                                <button type="button" class="btn btn-secondary ms-auto" data-bs-dismiss="modal">Cerrar</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Modal para Citas -->
                <div class="modal fade" id="citaModal" tabindex="-1" aria-labelledby="citaModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="citaModalLabel">Detalles de la Cita</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                            <div class="modal-body">
                                <p><strong>ID:</strong> <span id="citaId"></span></p>
                                <p><strong>Hora:</strong> <span id="citaHora"></span></p>
                                <p><strong>Servicio:</strong> <span id="citaServicio"></span></p>
                                <p><strong>Paciente:</strong> <span id="citaPaciente"></span></p>
                                <p><strong>Odontólogo:</strong> <span id="citaOdontologo"></span></p>
                                <p><strong>Estado:</strong> <span id="citaEstado"></span></p>
                                <p><strong>Importe:</strong> <span id="citaCosto"></span></p>
                            </div>
                            <div class="modal-footer d-flex justify-content-between">
                                <form id="formCompletarCita" action="ReprogramacionController" method="post" style="display: none; margin: 0;">
                                    <input type="hidden" name="idCita" id="btnIdCita" value="" />
                                    <input type="hidden" name="estado" id="btnEstadoCita" value="Confirmado" />
                                    <input type="hidden" name="accion" value="updateEstadoCompletadoCita" />
                                    <button class="btn btn-success fw-bold" type="submit">
                                        <i class="bi bi-check2-circle me-1"></i>Finalizar Atención (Marcar Completado)
                                    </button>
                                </form>
                                <button type="button" class="btn btn-secondary ms-auto" data-bs-dismiss="modal">Cerrar</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                document.querySelectorAll('.reserva-event').forEach(function (element) {
                    element.addEventListener('click', function () {
                        var modal = document.getElementById('reservaModal');
                        modal.querySelector('#reservaId').textContent = this.dataset.id;
                        modal.querySelector('#reservaHora').textContent = this.dataset.hora;
                        modal.querySelector('#reservaServicio').textContent = this.dataset.servicio;
                        modal.querySelector('#reservaPaciente').textContent = this.dataset.paciente;
                        modal.querySelector('#reservaOdontologo').textContent = this.dataset.odontologo;
                        modal.querySelector('#reservaEstado').textContent = this.dataset.estado;
                        var importeVal = parseFloat(this.dataset.importe);
                        modal.querySelector('#reservaImporte').textContent = (!isNaN(importeVal)) ? ('S/ ' + importeVal.toFixed(2)) : (this.dataset.importe || 'S/ 0.00');
                        modal.querySelector('#reservaDescripcion').textContent = this.dataset.descripcion;

                        var formComp = modal.querySelector('#formCompletarReserva');
                        if (formComp) {
                            if (this.dataset.estado && this.dataset.estado.trim() === 'Confirmado') {
                                formComp.style.display = 'block';
                                modal.querySelector('#btnIdReserva').value = this.dataset.id;
                            } else {
                                formComp.style.display = 'none';
                            }
                        }
                    });
                });

                // Manejar clics en eventos de cita
                document.querySelectorAll('.cita-event').forEach(function (element) {
                    element.addEventListener('click', function () {
                        var modal = document.getElementById('citaModal');
                        modal.querySelector('#citaId').textContent = this.dataset.id;
                        modal.querySelector('#citaHora').textContent = this.dataset.hora;
                        modal.querySelector('#citaServicio').textContent = this.dataset.servicio;
                        modal.querySelector('#citaPaciente').textContent = this.dataset.paciente;
                        modal.querySelector('#citaOdontologo').textContent = this.dataset.odontologo;
                        modal.querySelector('#citaEstado').textContent = this.dataset.estado;
                        var costoVal = parseFloat(this.dataset.costo);
                        modal.querySelector('#citaCosto').textContent = (!isNaN(costoVal)) ? ('S/ ' + costoVal.toFixed(2)) : (this.dataset.costo || 'S/ 0.00');

                        var formComp = modal.querySelector('#formCompletarCita');
                        if (formComp) {
                            if (this.dataset.estado && this.dataset.estado.trim() === 'Confirmado') {
                                formComp.style.display = 'block';
                                modal.querySelector('#btnIdCita').value = this.dataset.id;
                            } else {
                                formComp.style.display = 'none';
                            }
                        }
                    });
                });
            });
        </script>
    </body>
</html>
