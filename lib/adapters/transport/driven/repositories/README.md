# Transport Driven Repositories

Este directorio contiene las implementaciones _driven_ que satisfacen el puerto `ForQueryingTransport`. La implementación por defecto es `LocalTransportRepository`, la cual actúa como mock local y opera únicamente con el `TransportReservationsProvider`.

## Reemplazo del mock por una fuente real

Para pasar de este mock local a una integración real (por ejemplo, una API REST) se recomienda seguir los pasos formales siguientes:

1. **Crear una nueva implementación**  
   Defina una clase (por ejemplo `RemoteTransportRepository`) que implemente el puerto `ForQueryingTransport`. Esta clase debe encargarse de:
   - Consultar los servicios/agendas desde la fuente correspondiente (HTTP, base de datos, etc.).
   - Mapear la respuesta al modelo de dominio (`TransportAgendaModel`, `TransportServiceModel`, etc.).
   - Respetar las firmas existentes (`getStudentAgenda`, `getServices`, `createReservation`, etc.).

2. **Gestionar dependencias necesarias**  
   Si la implementación consume endpoints, inyecte los clientes HTTP, autenticadores u otros repositorios necesarios mediante su constructor para mantener la clase fácilmente testeable.

3. **Actualizar el service locator**  
   En `lib/service_locator.dart`, registre la nueva implementación en lugar de `LocalTransportRepository`:
   ```dart
   serviceLocator.registerLazySingleton<ForQueryingTransport>(
     () => RemoteTransportRepository(/* dependencias */),
   );
   ```
   Asegúrese de registrar también cualquier dependencia nueva (por ejemplo, un `TransportApiClient`).

4. **Mantener compatibilidad con la capa driver**  
   Ningún código en la UI o en `TransportApplicationService` debería cambiar, ya que estas capas sólo interactúan con el puerto `ForQueryingTransport` y el puerto driver `ForTransportInteractions`. Verifique que la nueva implementación reporte los mismos datos que el mock (o un superconjunto) para evitar regresiones.

5. **Eliminar o conservar el mock según necesidad**  
   - Si el mock ya no se usará, elimine `LocalTransportRepository` o muévalo a un directorio de pruebas/fixtures.
   - Si desea mantenerlo para entornos de desarrollo o pruebas offline, considere habilitarlo mediante una bandera de compilación o configuración (por ejemplo, evaluando `bool.fromEnvironment('USE_TRANSPORT_MOCK')` en `service_locator`).


## Buenas prácticas

- Mantenga la sincronización de modelos en un único lugar (el repositorio). No replique lógica de parsing en la capa driver.
- Implemente pruebas para la nueva clase (mocks de HTTP, fixtures, etc.) para asegurar que los contratos se mantienen estables.
- Revise los métodos `createReservation`, `cancelReservation` y `hasAvailability`, ya que típicamente son los primeros en requerir cambios cuando se comunica con un backend real.

Con esta estructura, siempre que el puerto `ForQueryingTransport` permanezca estable, la capa de presentación seguirá funcionando sin modificaciones al cambiar de mock a una fuente real.
