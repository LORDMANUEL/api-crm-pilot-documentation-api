# Auditoría funcional — middleware V7.1

**Corte de análisis:** 2026-11-06. **Fuente:** ZIP V7.1 recuperado y código Python/FastAPI inspeccionado localmente; documentos V7 incluidos con esa versión. **Alcance:** inspección estática y pruebas unitarias aisladas. **NO se ejecutaron llamadas a Pilot, SAP o DMS reales.**

## Método
1. Inventario de rutas, conectores, servicios, persistencia, plantillas y pruebas.
2. Inspección de riesgos documentados y del código de sesiones, escrituras y snapshots.
3. Ejecución `python -m unittest discover -s tests -q`: **27 tests, OK** (2026-11-06).
4. Clasificación: **implementado** = código presente; **verificado local** = test ejecutado; **pendiente externo** = no se comprobó el contrato/sistema; **bloqueado** = deshabilitado por política; **propuesto** = no construido.

## Matriz de realidad

| Funcionalidad | Código V7.1 | Evidencia local | Brecha |
|---|---|---|---|
| Setup, login, dashboard | Sí | Inspección y tests de laboratorio | RBAC/CSRF/TLS/gestión sesiones |
| Configurar empresas SAP | Sí | Inspección | Acceso externo, vault, permisos |
| Conector SAP (GET) | Sí | Pruebas aisladas | UAT Service Layer y paginación |
| Conector Pilot | Sí | Pruebas aisladas | Validación con proveedor |
| Observador Pilot | Sí | Inspección | Pipeline con snapshots V7 |
| Identidad vehículo/cliente | Parcial | Tests de reglas | Relaciones negocio complejas |
| Centro de datos V7 | Sí | Tests locales | Cobertura, concurrencia y calidad |
| Mappings V7 | Sí | Tests locales | Versiones, revisión, duplicados |
| Reserva inbound Pilot→SAP | Ruta existe, responde 410 | Inspección de código | Bloqueado por política |
| Reserva TEST | Laboratorio controlado | Tests de política | No habilitar sin autorización |
| Pagos y contratos | Exploratorio | Sin integración real | Conciliación P0 |
| Jobs y auditoría | Sí, SQLite | Inspección | Resiliencia y protección PII |

## Problemas prioritarios
### P0
- Secretos de integraciones almacenados sin cifrado específico en SQLite.
- Autenticación, roles, CSRF y controles web no uniformes.
- Pagos SAP sin reconciliación completa.
- Relaciones lead/venta/VIN/cliente facturable incompletas.
- Contrato oficial para cambios de reserva en Pilot no confirmado.

### P1
- Cobertura de snapshots no garantizada; faltan checkpoints y gestión explícita de paginación incompleta.
- Monitoreo Pilot y snapshots V7 no forman un único pipeline.
- SQLite, backups y concurrencia no preparados para escala empresarial.
- Gobierno de mappings, datos sensibles y observabilidad insuficientes.
- Identificador de versión API no consistente con el paquete distribuido.

## Riesgos específicos observados
- `app/core/store.py` define columnas de contraseñas de integración como texto y las persiste en SQLite; el hash de contraseña de usuarios no soluciona el problema de secretos de conectores.
- `app/main.py` aplica `SessionMiddleware`, validación limitada de `Origin` y una política de IP privada; no corresponde a autenticación robusta perimetral.
- `POST /api/inbound/pilot/reservation` está deprecado y retorna HTTP 410.
- `POST /api/v7/sap/snapshot` limita `page_size` y `max_pages`, por lo que sus resultados pueden estar incompletos.
- El catálogo HTTP del servicio declara versión `7.0.0`, diferente de la distribución V7.1.

## Decisiones y criterios de cierre
| ID | Prioridad | Entregable | Prueba de aceptación |
|---|---|---|---|
| AUD-01 | P0 | Secret manager y rotación | Ningún secreto legible en backups/DB/logs |
| AUD-02 | P0 | RBAC, sesiones y CSRF | Matriz de permisos y pruebas negativas |
| AUD-03 | P0 | Contratos de identidad/finanzas | Casos UAT reconciliados por evidencia |
| AUD-04 | P0 | Reserva Pilot certificada o bloqueada | Respuesta explícita y segura |
| AUD-05 | P1 | Motor de snapshots con checkpoints | Reanudación idempotente tras fallos |
| AUD-06 | P1 | Pipeline único de observación | Conteos verificables sin duplicación |
| AUD-07 | P1 | DB operacional y backups | Restauración/replay y carga controlada |
| AUD-08 | P1 | Versionado y CI | Misma versión en UI, API, changelog |

## No verificado
Disponibilidad de endpoints reales, validez de credenciales, catálogos completos, carga, sistemas DMS, seguridad de red corporativa, permisos SAP en producción, correcta conciliación financiera y satisfacción UAT. Ninguna afirmación de funcionamiento productivo puede derivarse de 27 tests aislados.

## Publicación
Esta auditoría se redactó para el repositorio **público de documentación**. No se incluye implementación, nombres de usuarios, claves, registros operacionales ni capturas internas. El middleware fuente requiere repositorio privado y revisión de secretos independiente.
