<div align="center">

# Pilot CRM · SAP Business One · DMS One

### API Reference & Integration Architecture

**Documentación técnica · Flujos de integración · Auditoría V7.1**

[Arquitectura](#arquitectura-de-referencia) · [Flujos](#flujo-de-integración) · [Estado funcional](#estado-funcional-verificado) · [PRD / TRD / APP Flow](#especificaciones-y-auditoría-v71)

</div>

---

> [!IMPORTANT]
> **Repositorio público de documentación.** El código operativo del middleware corporativo V7.1, sus bases de datos y configuraciones deben mantenerse en un repositorio privado. Los esquemas siguientes son diagramas de referencia, no una certificación de producción.

Repositorio de referencia para la API de **Pilot CRM** y su integración con **SAP Business One (Service Layer)** y **DMS One**.

Repositorio de referencia para el uso de la API de **Pilot CRM** y la documentación de integración con **SAP Business One (Service Layer)** y **DMS One**. Los ejemplos de este repositorio son educativos y deben ejecutarse exclusivamente con credenciales y registros de prueba autorizados.

> **Estado:** documentación y ejemplos de API. **No contiene el código fuente del middleware interno YUDE Pilot V7.1 ni constituye una implementación productiva.** El middleware debe mantenerse en un repositorio **privado** separado.

## Índice

- [Alcance](#alcance)
- [Arquitectura de referencia](#arquitectura-de-referencia)
- [Flujo de integración](#flujo-de-integración)
- [Estado funcional verificado](#estado-funcional-verificado)
- [Autenticación Pilot](#autenticación-pilot)
- [Ejemplos y endpoints](#mapa-de-ejemplos)
- [Seguridad](#seguridad)
- [PRD, TRD, APP Flow y auditoría](#especificaciones-y-auditoría-v71)
- [Pruebas y mantenimiento](#pruebas-y-validación)

## Alcance

- Ejemplos de autenticación y consulta de catálogos, prospectos/leads y eventos de Pilot.
- Contratos de referencia y pautas para consumir la API de Pilot.
- Diseño de integración, límites operativos, trazabilidad y medidas de protección.
- Este repositorio **no es documentación oficial del proveedor**; confirmar métodos, nombres de `FlowName`, límites y campos contra la documentación vigente de Pilot.

## Arquitectura de referencia

```mermaid
flowchart LR
    A[Pilot CRM] <-->|API / eventos autorizados| M[Middleware privado]
    M <-->|GET de solo lectura| S[SAP B1 Service Layer]
    M <-->|consultas permitidas| D[DMS One]
    M --> Q[(Auditoría, caché e idempotencia)]
```

**Política de integración:** en SAP productivo usar únicamente autenticación, consultas de lectura y cierre de sesión; las escrituras requieren pruebas y autorización independiente en una empresa TEST. No interpretar los ejemplos de actualización de leads como habilitación de escrituras en SAP.

## Flujo de integración

### Ciclo de consulta y observación

```mermaid
sequenceDiagram
    autonumber
    actor IT as Operador TI
    participant UI as Panel interno
    participant API as Middleware privado
    participant P as Pilot CRM API
    participant S as SAP B1 Service Layer
    participant DB as Auditoría / snapshots
    IT->>UI: Seleccionar empresa y consulta
    UI->>API: Solicitud autenticada
    API->>P: Lectura autorizada (paginada)
    P-->>API: Registros y estado
    API->>S: Login (cuenta de lectura)
    API->>S: GET entidad / datos vinculados
    S-->>API: Respuesta
    API->>S: Logout
    API->>DB: Normalizar, correlacionar y auditar
    API-->>UI: Resultado y cobertura
    UI-->>IT: Estado, evidencia y excepciones
```

### Política de escritura

```mermaid
flowchart TD
    A[Solicitud de operación] --> B{Entorno SAP}
    B -->|PRODUCCIÓN| C[Permitir solo Login / GET / Logout]
    C --> D{Operación de negocio de escritura?}
    D -->|Sí| E[Bloquear y auditar]
    D -->|No| F[Consultar con permisos mínimos]
    B -->|TEST autorizado| G{Autorización y validaciones}
    G -->|No| E
    G -->|Sí| H[DRY-RUN y revisión]
    H --> I{Aprobación explícita?}
    I -->|No| E
    I -->|Sí| J[Ejecutar prueba y validar resultado]
```

> El bloque TEST representa el procedimiento objetivo sujeto a autorizaciones. No implica que existan escrituras de producción activas ni que la API externa haya sido certificada.

### Mapa de navegación funcional (laboratorio)

```mermaid
flowchart LR
  A[Login / Setup] --> B[Dashboard]
  B --> C[Empresas y SAP]
  B --> D[Pilot: catálogos, stock, leads]
  B --> E[Vehículos y mappings]
  B --> F[Centro de datos / snapshots]
  B --> G[Observador y auditoría]
  C --> H[Prueba de conexión]
  D --> I[Consulta / seguimiento]
  E --> J[Reconciliación pendiente]
  F --> K[Cobertura y excepciones]
```

## Estado funcional verificado

| Área | Estado local V7.1 | Falta para producción |
|---|---|---|
| Panel, setup y login | Código presente | RBAC/CSRF/sesiones y TLS |
| SAP Service Layer | Conector de lectura presente | Validación de permisos, paginación y carga |
| Pilot CRM | Consultas y observador presentes | Contratos, límites y pruebas externas |
| Snapshots y mappings | Implementación parcial en laboratorio | Cobertura, checkpoints y control de cambios |
| Reserva Pilot → SAP | Ruta heredada deshabilitada (HTTP 410) | Contrato y flujo aprobado |
| Conciliación comercial y financiera | Parcial | Validación de relaciones y evidencia |
| Pruebas unitarias locales | 27/27 aprobadas en entorno aislado | Integración, seguridad y UAT |

### Hoja de ruta visual

```mermaid
flowchart LR
    P0["Fase 0 · Seguridad<br/>Secretos, roles, CSRF"] --> P1["Fase 1 · Contratos<br/>API, mappings, paginación"]
    P1 --> P2["Fase 2 · Reconciliación<br/>Reservas, documentos, pagos"]
    P2 --> P3["Fase 3 · Resiliencia<br/>Jobs, reintentos, auditoría"]
    P3 --> P4["Fase 4 · UAT<br/>Solo lectura y aprobación"]
```

Estos flujos distinguen lo observado en el código local de los trabajos **propuestos**; no se han ejecutado pruebas contra servicios SAP/Pilot productivos.

## Autenticación Pilot

Base de API identificada en los ejemplos históricos: `https://api.pilotsolution.net/v1`. Se deben utilizar variables de entorno o un gestor de secretos, **nunca credenciales dentro de Git**.

```bash
export PILOT_USERNAME="usuario-de-pruebas@example.invalid"
# Proveer la clave de forma segura, fuera del shell history
read -rsp "Clave Pilot: " PILOT_PASSWORD; echo
export PILOT_PASSWORD

# Script de autenticación (requiere curl, jq y variables anteriores)
bash autorizacion.bash
```

El endpoint histórico usa parámetros `username` y `password` en la URL. Por tanto, revisar exposición en registros de proxies, historial de comandos y herramientas de observabilidad; usar el mecanismo más seguro soportado por el proveedor. El script ya no imprime ni persiste tokens.

## Mapa de ejemplos

| Archivo / carpeta | Objetivo |
|---|---|
| `autorizacion.bash` | Autenticación con credenciales suministradas en tiempo de ejecución |
| `Peticion-dato-Maestro.bash` | Ejemplos de consulta de datos maestros (revisar payload y valores antes de ejecutar) |
| `propescts.bash` | Ejemplos históricos de prospectos |
| `leads/bash/` | Lectura y operaciones de leads; **no ejecutar escrituras con datos reales sin autorización** |
| `leads/doc/` | Notas de operaciones de leads |
| `estructura/estructura.md` | Estructura del sobre de solicitud |
| `docs/INTEGRACION_SAP_DMS_PILOT.md` | Arquitectura y políticas del middleware |

Los ejemplos heredados pueden contener valores ilustrativos y contratos desactualizados: no están certificados contra una instancia en vivo.

## Seguridad

Consultar [SECURITY.md](SECURITY.md) para el tratamiento de credenciales expuestas, rotación, historial Git y revisión de datos.

**Nunca incluir:** contraseñas, tokens, cookies, archivos `.env`, bases de datos, VIN y datos personales reales, registros de SAP o direcciones internas.

## Middleware SAP / DMS / Pilot

La línea de desarrollo interna recuperada comprende V4, V5, V6.3 y V7.1. Su implementación Python/FastAPI, reglas de escritura TEST, caché y auditoría pertenecen a un repositorio privado distinto. Aquí solo documentamos interfaces y buenas prácticas no sensibles: [integración](docs/INTEGRACION_SAP_DMS_PILOT.md).

## Pruebas y validación

Revisiones recomendadas antes de cada PR:
- Escaneo de secretos (Gitleaks u herramienta equivalente) y revisión humana del diff.
- Comprobación de sintaxis de ejemplos Bash y documentación Markdown.
- Pruebas con fixtures sintéticos, sin conectividad a producción.
- Validación de límites, reintentos, idempotencia y manejo de códigos HTTP con el proveedor.

**Aviso:** las pruebas de middleware local reportadas previamente no equivalen a pruebas ejecutadas en este repositorio ni a certificación de integración productiva.


## Especificaciones y auditoría V7.1

La documentación siguiente distingue la implementación examinada de los requisitos futuros. **El código interno del middleware no se aloja en este repositorio público.**

| Documento | Contenido |
|---|---|
| [PRD — Requisitos de producto](docs/PRD_INTEGRACION_PILOT_SAP.md) | Objetivos, usuarios, requisitos, alcance, criterios de aceptación y fases |
| [TRD — Diseño técnico](docs/TRD_INTEGRACION_PILOT_SAP.md) | Arquitectura, contratos, persistencia, seguridad, pruebas y condiciones de salida |
| [APP Flow](docs/APP_FLOW_INTEGRACION_PILOT_SAP.md) | Navegación, onboarding, snapshots, reservas y manejo de errores |
| [Auditoría V7.1](docs/AUDITORIA_FUNCIONAL_V7_1.md) | Qué existe, qué se verificó localmente, deuda P0/P1 y límites de evidencia |

**Resultado de auditoría local:** 27/27 pruebas aisladas aprobadas. No se ha verificado el comportamiento frente a Pilot, SAP o DMS productivos. La actualización de reserva inbound histórica está deprecada y retorna HTTP 410.

## Mantenimiento

Abrir un PR para cambios en contratos, ejemplos o documentación y revisar implicaciones de seguridad. Evitar subir paquetes ZIP completos de middleware al repositorio público.
