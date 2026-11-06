# TRD — Integración Pilot CRM / SAP B1 / DMS One

**Estado:** diagnóstico del laboratorio V7.1 + arquitectura objetivo propuesta. No corresponde a certificación productiva.

## 1. Línea base verificada por inspección de código
- Backend Python 3.12 / FastAPI, plantillas Jinja2, SQLite.
- Conectores HTTP para Pilot CRM y SAP Business One Service Layer.
- Monitoreo periódico Pilot, normalización, persistencia de eventos, snapshots y mappings.
- Rutas para empresas, Pilot, vehículos, auditoría, centro de datos, mappings y capacidades.
- Suites locales `unittest`: **27 de 27 aprobadas** en ejecución aislada el 6 de noviembre de 2026. No se conectó a Pilot ni SAP.
- El endpoint histórico de reserva inbound está **deprecado y responde HTTP 410**; no considerarlo funcional.

## 2. Arquitectura objetivo

```text
Panel autenticado ─► API privada ─► Servicios de dominio ─► Repositorio operacional
                           │                 │
                           │                 ├─► Colas/jobs y auditoría
                           ├─► Pilot adapter  └─► Normalización / reconciliación
                           └─► SAP reader (Service Layer, GET)
                                         │
                                   Entornos separados
```

## 3. Componentes y contratos
| Componente | Responsabilidad | Restricción |
|---|---|---|
| API/UI | Autenticación, roles, consultas, jobs explícitos | Evitar exponer internals/secretos |
| Adaptador Pilot | Auth, lectura paginada, límites y reintentos | Confirmar métodos y errores del proveedor |
| SAP Reader | Login, GET, logout y selección CompanyDB explícita | Bloqueo integral de escrituras productivas |
| Normalizador | Esquemas canónicos de vehículo/cliente/venta | Conservar evidencia y origen |
| Store | Snapshots, hashes, mappings, job runs, auditoría | Redacción PII, WAL/backup, migraciones |
| Scheduler/queue | Ejecución desacoplada, checkpoint y backoff | No saturar Service Layer |

## 4. Modelo conceptual de entidades
- `source_record`: `source`, `environment`, `company`, `entity`, `external_id`, `payload_hash`, `observed_at`.
- `identity_link`: `source_id`, `target_id`, `link_type`, `evidence`, `confidence/status`, `reviewed_by`.
- `sync_run`: `job_id`, `cursor/checkpoint`, `page_count`, `records_seen`, `complete`, `error_code`, `duration_ms`.
- `audit_event`: `actor`, `action`, `correlation_id`, `result`, `timestamp`. No registrar tokens, credenciales ni payloads personales completos.

## 5. Hallazgos técnicos de V7.1

| Prioridad | Evidencia de código / documento | Riesgo | Acción |
|---|---|---|---|
| P0 | Credenciales Pilot/SAP en columnas de SQLite | Extracción de secretos si se copia la DB | Vault o cifrado OS + migración/rotación |
| P0 | Autenticación por sesión y verificación Origin parcial | CSRF, permisos inconsistentes | Tokens CSRF, RBAC, cookies Secure, pruebas negativas |
| P0 | Conciliación de pagos/contratos no completada | Estado comercial incorrecto | Contrato y evidencia financiera |
| P0 | Relaciones lead/venta/VIN/bill-to parciales | Identidad errónea | Resolver entidades y pruebas de mapeo |
| P0 | Actualización de reserva en Pilot sin contrato certificado | Escritura incorrecta | Bloquear hasta obtener especificación |
| P1 | Snapshots con límites `page_size` / `max_pages` | Cobertura parcial presentada como completa | Checkpoints, OData nextLink, estado de completitud |
| P1 | Observador Pilot separado de carga V7 | Duplicación y diferencias de estado | Pipeline único |
| P1 | SQLite bajo concurrencia y snapshots | Bloqueos, integridad, backups | WAL, transacciones, plan PostgreSQL |
| P1 | Estado de versión HTTP puede diferir del paquete V7.1 | Confusión operativa | Versión única por build |
| P1 | Protección LAN por IP privada | Seguridad insuficiente como único perímetro | TLS, reverse proxy, identidad/ACL |

## 6. Seguridad y operación
- **Default deny** en escrituras SAP productivo en servicio, gateway, roles y pruebas de regresión.
- Separar cuentas y secretos TEST/PROD; sesiones mínimas, TLS verificado y certificados confiables.
- Protección CSRF consistente en operaciones mutantes; `SameSite` no reemplaza CSRF.
- Permisos de mínimos privilegios; logs redactados; auditoría inmutable cuando corresponda.
- Rate limit/bulkhead/circuit breaker y backoff con jitter según respuesta del proveedor.
- Observabilidad de errores por origen, latencia P95/P99, colas, reintentos y cobertura.
- Backups y restauración probados; estrategia de migraciones reversibles.
- Prohibido publicar código de integración interna en repositorios públicos.

## 7. Estrategia de pruebas
1. **Unitarias:** normalización, mapeo, idempotencia, write-policy, auth.
2. **Contrato:** fixtures representativos de Pilot, SAP OData, códigos HTTP y paginación.
3. **Integración TEST:** permisos, TLS, límites, fallos parciales, reconexión y logout.
4. **Seguridad:** CSRF, escalada de privilegios, secretos, inyección, manipulación de mapeos, SSRF.
5. **Carga:** datasets sintéticos, límites conservadores, métricas y cancelación segura.
6. **UAT:** casos aprobados de vehículos, reservas, ventas, documentos y pagos.
7. **Rollback:** recuperación comprobada de DB, configuración y versión de código.

## 8. Condición para producción
No habilitar automatización hasta cerrar P0, tener pruebas de contrato y UAT con evidencias, y aprobar un despliegue controlado inicialmente **solo lectura**.
