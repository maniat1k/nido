# Nido — MVP Scope

## 1. Objetivo del MVP

Construir una versión funcional que permita:

- Publicar prendas
- Visualizar prendas en un feed
- Ver el detalle de una prenda

El MVP busca validar el uso básico del producto, no resolver todo el proceso de compra/venta.

---

## 2. Funcionalidades incluidas

### 2.1 Publicación de prendas (S1)

El usuario puede:

- Crear una prenda
- Cargar:
  - Imagen
  - Título
  - Descripción
  - Precio (opcional o fijo según definición)
  - Estado de la prenda (nuevo, usado, etc.)

Requisitos:

- Flujo simple
- Sin validaciones complejas
- Sin necesidad de login (si se define así)

---

### 2.2 Feed principal (S2)

El usuario puede:

- Ver un listado de prendas
- Navegar verticalmente (scroll)
- Visualizar:
  - Imagen
  - Título
  - Precio

Requisitos:

- Carga rápida
- UI clara tipo tarjetas
- Sin filtros avanzados en esta etapa

---

### 2.3 Detalle de prenda (S3)

El usuario puede:

- Ver información completa de la prenda:
  - Imagen
  - Descripción
  - Precio
  - Estado

Opcional en MVP:

- Botón de contacto simple (sin chat integrado)

---

## 3. Funcionalidades explícitamente fuera de alcance

Estas funcionalidades NO forman parte del MVP:

### Usuarios
- Registro / login completo
- Perfiles de usuario

### Interacción
- Chat en tiempo real
- Sistema de mensajes

### Transacciones
- Pagos dentro de la app
- Carrito de compras
- Checkout

### Plataforma
- Notificaciones push
- Sistema de favoritos persistente (puede existir localmente)

### Búsqueda y filtros
- Filtros avanzados
- Categorías complejas

---

## 4. Definiciones técnicas simplificadas

Para el MVP:

- Se prioriza uso de datos mock o almacenamiento simple
- No se requiere backend robusto en esta etapa
- Persistencia puede ser básica o incluso simulada

---

## 5. Criterios de finalización del MVP

El MVP se considera completo cuando:

- Se puede publicar una prenda sin errores
- El feed muestra prendas correctamente
- Se puede navegar al detalle de cada prenda
- La app es usable por una persona externa sin explicación

---

## 6. Riesgos controlados

Se acepta que el MVP:

- No tenga seguridad completa
- No tenga persistencia definitiva
- No esté optimizado al máximo

El foco es validar uso, no escalar.

---

## 7. Relación con sprints

- S1 → Publicación de prenda
- S2 → Feed principal
- S3 → Detalle de prenda

El MVP queda completo al finalizar S3.