# PRD — Integración Pilot CRM ↔ SAP Business One / DMS One

**Estado:** borrador para revisión. **Versión de referencia:** middleware interno V7.1 (laboratorio). **Confidencialidad:** este documento describe objetivos generales, sin código ni datos internos.

## 1. Problema
Las operaciones comerciales en Pilot y las operaciones financieras/vehiculares de SAP/DMS One no comparten necesariamente el mismo identificador ni el mismo estado. Copiar información manualmente genera duplicados, diferencias de estados, trazabilidad insuficiente y riesgo de afectar el ERP con operaciones no autorizadas.

## 2. Objetivo del producto
Crear una capa desacoplada de observación, normalización y reconciliación con auditoría que ofrezca evidencia verificable entre entidades comerciales de Pilot y registros autorizados de SAP/DMS, sin reemplazar a ninguno de los tres sistemas.

### Objetivos medibles propuestos (por aprobar)
- 100% de operaciones de integración con correlación, origen, fecha, resultado e intento registrado.
- Cero escrituras de negocio sobre SAP productivo desde el middleware.
- Cero claves, tokens, cookies o PII en logs destinados a observabilidad.
- Pruebas de contrato y UAT sobre datos sintéticos/anónimos antes de habilitar flujos.
- Duplicados de eventos identificados y procesados idempotentemente.

## 3. Personas usuarias
- **Administrador TI:** configura conectores, accesos, estado operativo, auditoría y entorno.
- **Operador comercial:** consulta estado comercial de unidades y leads sin alterar el ERP.
- **Responsable de operaciones:** investiga diferencias de reservas y disponibilidad.
- **Auditor/soporte:** reconstruye eventos mediante identificadores de correlación, sin acceder a secretos.

## 4. Alcance

| ID | Requisito | Prioridad | Estado constatado en V7.1 |
|---|---|---|---|
| FR-01 | Administración y selección explícita de empresa/entorno | Must | Implementación local |
| FR-02 | Conector de lectura SAP Service Layer | Must | Implementado, sin UAT externo |
| FR-03 | Conector de lectura Pilot (maestros, stock, ventas, leads) | Must | Implementado, contrato externo pendiente |
| FR-04 | Observación y detección de cambios | Must | Implementado parcialmente integrado |
| FR-05 | Normalización de vehículo, cliente y vínculos de negocio | Must | Parcial; evidencia insuficiente para algunos vínculos |
| FR-06 | Vista de trazabilidad y auditoría | Must | Implementación local |
| FR-07 | Snapshots y consulta por entidad | Should | Implementado con límites de cobertura |
| FR-08 | Mappings revisables y versionados | Should | Editor local; gobierno de cambios pendiente |
| FR-09 | Conciliación pagos/facturas/contratos | Must antes de producción | Pendiente |
| FR-10 | Notificación de excepciones y reintentos seguros | Should | Parcial |
| FR-11 | Actualización de reserva comercial en Pilot | Future, requiere API oficial | No validado |
| FR-12 | Escrituras SAP productivo | Excluido | Prohibido |

## 5. Reglas de negocio
1. No inferir una empresa cuando haya ambigüedad; el usuario o el evento debe resolverla explícitamente.
2. Diferenciar reserva comercial en Pilot de reserva operativa gestionada en SAP/DMS.
3. Separar cliente comercial, titular de la unidad y cliente de facturación.
4. Nunca modificar registros productivos de SAP desde esta integración.
5. Un VIN o teléfono aislado no acredita identidad ni relación comercial definitiva; exigir evidencia cruzada.
6. Las escrituras de prueba requieren autorización, allowlist TEST, simulación, auditoría y verificación posterior.

## 6. Exclusiones
- Reemplazar CRM o ERP; crear reservas operativas automáticamente desde Pilot; sincronización bidireccional productiva; automatizar cobros y facturas; publicar configuraciones, claves o información de clientes.

## 7. Criterios de aceptación
- **AC-01:** credenciales ausentes o inválidas producen error controlado sin exposición de secretos.
- **AC-02:** una empresa desconocida/inactiva no se enruta silenciosamente a otra.
- **AC-03:** toda tentativa de escribir en SAP productivo falla sin emitir solicitud de negocio.
- **AC-04:** duplicar evento no duplica efecto; se conserva trazabilidad de reintento.
- **AC-05:** un snapshot incompleto declara cobertura y límites; nunca se presenta como inventario completo.
- **AC-06:** formularios y API aplican autenticación/autorización consistente y protección CSRF.
- **AC-07:** la conciliación de ventas, pagos y reservas usa evidencia documental antes de mostrar un estado confirmado.
- **AC-08:** instalación, backup, restauración y rollback se comprueban sobre entorno TEST.

## 8. Roadmap sugerido
- **Fase 0 — Seguridad P0:** rotación de secretos, almacenamiento seguro, controles web, pruebas de autorización.
- **Fase 1 — Contratos y datos:** validar APIs, paginación, relaciones, catálogo de campos y pruebas de contrato.
- **Fase 2 — Reconciliación:** reservas, facturas, pagos y trazabilidad consistente.
- **Fase 3 — Resiliencia:** workers desacoplados, checkpoints, idempotencia, métricas y recovery.
- **Fase 4 — UAT/producción:** pruebas de carga controlada, aprobación TI/negocio, piloto en solo lectura y rollback.

## 9. Supuestos no verificados
Contratos reales de Pilot, disponibilidad y permisos SAP, datos de DMS One, volumen esperado, SLO y decisiones de operación requieren confirmación con responsables antes de cerrar el PRD.
