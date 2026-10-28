import codecs

path = 'src/main/webapp/PDCReportes.jsp'
with open(path, 'rb') as f:
    content = f.read().decode('latin1')

chunk1 = '''                        <!-- Gr\xe1fico de L\xednea para Citas -->
                        <div style="width: 45%;">
                            <h6 class="text-center">Tendencias de Citas</h6>
                            <canvas id="trendLineChart"></canvas>
                        </div>
                    </div>
                </div>'''

rep1 = '''                        <!-- Gr\xe1fico de L\xednea para Citas -->
                        <div style="width: 45%;">
                            <h6 class="text-center">Tendencias de Citas</h6>
                            <canvas id="trendLineChart"></canvas>
                        </div>
                    </div>
                    
                    <div class="d-flex justify-content-around align-items-center mt-5">
                        <div style="width: 80%;">
                            <h6 class="text-center">Ingresos Mensuales (S/.)</h6>
                            <canvas id="ingresosChart"></canvas>
                        </div>
                    </div>
                </div>'''

content = content.replace(chunk1, rep1)

chunk2 = '''            const meses = [];
            const totalReservas = [];
            const totalCitas = [];

            <c:forEach var="reporte" items="${reporteMensual}">
            meses.push("${reporte.mes}");
            totalReservas.push(${reporte.totalReservas});
            totalCitas.push(${reporte.totalCitas});
            </c:forEach>;'''

rep2 = '''            const meses = [];
            const totalReservas = [];
            const totalCitas = [];
            const totalIngresos = [];

            <c:forEach var="reporte" items="${reporteMensual}">
            meses.push("${reporte.mes}");
            totalReservas.push(${reporte.totalReservas});
            totalCitas.push(${reporte.totalCitas});
            totalIngresos.push(${reporte.totalIngresos});
            </c:forEach>;'''

content = content.replace(chunk2, rep2)

chunk3 = '''                    }
                }
            });

            // Datos din\xe1micos desde la base de datos'''

rep3 = '''                    }
                }
            });

            // Gr\xe1fico de Ingresos
            const ctxIngresos = document.getElementById('ingresosChart').getContext('2d');
            new Chart(ctxIngresos, {
                type: 'bar',
                data: {
                    labels: meses,
                    datasets: [
                        {
                            label: 'Ingresos Mensuales (S/.)',
                            data: totalIngresos,
                            backgroundColor: 'rgba(54, 162, 235, 0.5)',
                            borderColor: 'rgba(54, 162, 235, 1)',
                            borderWidth: 1
                        }
                    ]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });

            // Datos din\xe1micos desde la base de datos'''

content = content.replace(chunk3, rep3)

with open(path, 'wb') as f:
    f.write(content.encode('latin1'))

print("Done replacing.")
