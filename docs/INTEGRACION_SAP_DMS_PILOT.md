# Integración de referencia: Pilot CRM ↔ middleware ↔ SAP B1 / DMS One

## Propósito y alcance

Documentación pública de alto nivel para la integración YUDE Pilot. No incluye direcciones corporativas, credenciales, bases reales, mapeos internos ni código del middleware.

## Flujo de lectura

```text
SAP Business One / DMS One
   │ consultas autorizadas y limitadas
   ▼
Middleware privado (FastAPI)
   │ validación → normalización → mapeo → auditoría
   ▼
Pilot CRM (consultas o eventos autorizados)
```

## Flujo Pilot → SAP/DMS

1. Recibir un evento Pilot y verificar autenticidad de origen y esquema.
2. Validar identificadores (por ejemplo, correlación de vehículo/cliente) con datos sintéticos durante pruebas.
3. Aplicar mapeos versionados, reglas de consistencia, idempotencia y enrutamiento por empresa.
4. Para SAP productivo, **consultar únicamente** mediante Service Layer; no ejecutar POST/PATCH/DELETE de negocio.
5. Registrar identificador de correlación, estado, intentos, duración y errores **sin** guardar tokens ni PII.
6. Definir cuarentena y reintentos con backoff para errores transitorios.

## Separación de entornos

| Entorno | SAP | Pilot | Política |
|---|---|---|---|
| Desarrollo | mocks / fixtures | sandbox o mocks | Sin recursos reales |
| TEST autorizado | lecturas y escrituras expresamente habilitadas | pruebas controladas | DRY-RUN y auditoría previa |
| Producción | login, GET, logout | operaciones autorizadas según contrato | Escritura SAP deshabilitada |

La política final depende de controles efectivos en código, identidades y permisos, no solo de señales visuales.

## Controles técnicos sugeridos

- Pool de sesiones y límite de concurrencia de Service Layer.
- Throttling de API Pilot conforme al contrato vigente.
- Caché con TTL, deduplicación y paginación.
- Correlation ID y registros redactados.
- Secretos externos, TLS verificado y segregación de empresas.
- Pruebas de contrato, simulación de 429/5xx y recuperación de fallos.

## Versiones internas recuperadas

Se encontraron artefactos V4, V5, V6.3 y V7.1 del proyecto Python/FastAPI. **Estos no se publican en este repositorio**. Sus capacidades deben cotejarse contra el código privado antes de calificarlas como funcionales o productivas.

## Pendientes

- Acordar la ubicación y la privacidad del repositorio independiente del middleware.
- Completar una auditoría de secretos y datos antes de importar su código.
- Confirmar contratos y endpoints reales con documentación vigente de Pilot.
- Ejecutar pruebas en laboratorio, sin usar producción como entorno de prueba.
