# Política de seguridad

## Acción inmediata: credenciales expuestas

Este repositorio público contenía una contraseña de Pilot incrustada en `autorizacion.bash` y `rutas.bash`, además de una cookie de sesión en un ejemplo. **Estas credenciales deben considerarse comprometidas**, aunque hayan sido retiradas de los archivos en una rama nueva.

1. Revocar/rotar la contraseña de la cuenta afectada directamente en Pilot; invalidar sesiones y tokens asociados.
2. Revisar accesos y eventos de autenticación durante el período de exposición.
3. Revisar forks, caches, clones y el **historial de Git**: un PR que borra el valor no borra los commits anteriores.
4. Coordinar una limpieza del historial con el responsable del repositorio y sus colaboradores; después volver a rotar los secretos si procede.
5. Configurar escaneo automático de secretos y protección de push; comprobar scripts y documentación antes de publicar.

No describir una eliminación en la rama actual como remediación completa.

## Normas del repositorio

- Usar variables de entorno, secretos del CI o un gestor de credenciales; no versionar `.env`.
- Excluir bases de datos, backups, cookies de sesión, payloads reales de clientes y logs.
- Sustituir muestras por fixtures sintéticos sin PII.
- Exigir revisión de cambios en contratos que ejecuten escrituras.
- **No subir código o configuraciones del middleware corporativo a este repositorio público.**

## Comunicación de incidentes

Reportar cualquier exposición al propietario del repositorio por un canal privado. No publicar secretos ni trazas sensibles en issues o PR.
