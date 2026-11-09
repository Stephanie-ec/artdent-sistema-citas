# Carillas dentales: precio de referencia y fórmula

Fecha de consulta: 7 de noviembre de 2026. Precios en soles peruanos (S/), salvo
donde se indique USD.

## Decisión

El servicio 8 del catálogo se llama **Carillas Dentales** y se cobra como
**carilla de porcelana por pieza**:

```
Precio unitario del servicio = S/ 1,500.00
```

No es el precio de una sonrisa completa ni de una arcada. El sistema agenda y
cobra una pieza; si el tratamiento requiere varias, el Total referencial se
calcula con la fórmula de abajo y el presupuesto final se confirma en la
evaluación clínica. El precio es editable desde el módulo de Servicios del
administrador y en `db_artdent_apf2_completo.sql` / `update_apf2_carillas.sql`.

## Fórmula

Sea `n` el número de carillas de porcelana indicadas para el paciente (`n >= 1`):

```
Total referencial = S/ 1,500.00 × n
```

Ejemplos:

| Carillas | Total referencial |
|---:|---:|
| 1 | S/ 1,500.00 |
| 6 | S/ 9,000.00 |
| 8 | S/ 12,000.00 |
| 10 | S/ 15,000.00 |

La fórmula no aplica descuentos automáticos. Los paquetes de 6 a 12 piezas que
ofrecen algunas clínicas son cotizaciones comerciales y no una regla del sistema.
Si el paciente requiere resina en lugar de porcelana, se debe crear/editar otro
servicio con su propio precio; no se mezcla con esta tarifa.

## Fuentes de mercado

| Fuente | Precio publicado | Uso en la decisión |
|---|---|---|
| Dental Geovanna Pizarro (Lima), guía 2025 | Porcelana S/ 1,000–1,400 por pieza; resina S/ 600–900 | Rango local de referencia |
| Dental Geovanna Pizarro (Lima), guía 2026 | Porcelana S/ 1,500–2,800 por pieza; resina S/ 600–1,200 | Confirma el límite inferior de S/ 1,500 |
| Climedent / Carillas Dentales Lima | Porcelana S/ 1,500–3,500; composite S/ 500–1,500; zirconio S/ 2,500–4,500 | Rango de clínicas de Lima |
| Solución Dental (Lima) | Porcelana desde S/ 1,850; resina aproximadamente S/ 550 | Contraste de precio de porcelana |
| Smile Design Perú (Lima) | Porcelana USD 450 ≈ S/ 1,675; resina USD 180 ≈ S/ 670 | Contraste en Lima |
| Smiles Perú (Miraflores) | Porcelana desde USD 445 ≈ S/ 1,660 por diente | Contraste en Lima |

Enlaces consultados:

- https://dentalgeovannapizarro.com/blog-carillas-dentales-procedimiento
- https://dentalgeovannapizarro.com/blog-precios-carillas-dentales-surco-lima-2025
- https://carillasdentaleslima.com/
- https://soluciondental.pe/estetica/carillas
- https://smiledesignperu.com/precio-de-carillas-dentales-en-peru
- https://smilesperu.com/es/precios

## Por qué S/ 1,500

- Está dentro del rango local 2026 para porcelana (S/ 1,500–2,800).
- Es el límite inferior del rango, adecuado para una clínica que recién
  activa el servicio y no para una tarifa premium.
- No se usó el precio de resina (S/ 350–900) porque la descripción del servicio
  y la imagen corresponden a carillas de porcelana.
- Un valor menor, como los S/ 350 anteriores, quedaba por debajo hasta del
  precio de resina documentado y no era defendible como precio de mercado.

## Verificación en base

```sql
SELECT idServicio, TipoServicio, Costo, Lema
FROM Servicio
WHERE idServicio = 8;
```

Resultado esperado: `Carillas Dentales`, `1500.00`, lema con «desde S/ 1,500 por
pieza». La asignación debe incluir a Rubén Cuadros y Lucía Herrera.
