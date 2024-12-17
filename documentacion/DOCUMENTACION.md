# Documentación

En esta documentación detallo los pasos seguidos para desarrollar este proyecto, las decisiones tomadas, los retos enfrentados y los planes a futuro.

---

## Resumen

Este proyecto consiste en diseñar una infraestructura que incluye dos máquinas virtuales (MV) en una red virtual (vNet): una dedicada a la base de datos (BD) y otra para respaldos. Además, otra vNet alberga un clúster donde se despliega el frontend y backend de la aplicación. El objetivo principal es que el backend se conecte con la base de datos para registrar información, permitiendo su interacción a través del frontend.

---

## Estructura

Este proyecto está dividido en tres repositorios:

- **Repositorio principal**: Contiene la infraestructura, workflows de automatización, playbooks de Ansible y charts de Helm.
- **Repositorio backend**: Código del backend y su integración CI/CD.
- **Repositorio frontend**: Código del frontend y su integración CI/CD.

Links a los repos secundarios:
- [Backend](https://github.com/stemdo-labs/final-project-gestion-rrhh-backend-ValentinoSanchez00)
- [Frontend](https://github.com/stemdo-labs/final-project-gestion-rrhh-frontend-ValentinoSanchez00)

---

## Repositorio principal

El repositorio principal consta de cuatro secciones clave:

### 1. Actions y workflows

La mayoría de los workflows son de tipo `dispatch` o reutilizables. Los principales workflows incluyen:

- **InfrastructurePlan**: Genera un plan de infraestructura en las PRs para detectar errores.
- **InfrastructureApply**: Aplica los cambios de infraestructura al cerrar una PR.
- **Backup**: Realiza un backup de la BD cada 5 horas (actualmente deshabilitado por límites de uso).
- **InfraestructureDown**: Dismantela la infraestructura automáticamente.

Además, incluye workflows reutilizables, como `SubirCharts` y `SubirDockerfiles`, utilizados por los repos secundarios.

---

### 2. Playbooks de Ansible

Incluyen scripts para instalar dependencias como Ansible, realizar backups e instalar PostgreSQL. Se ejecutan automáticamente en los hosts definidos en `inventory.ini`.

---

### 3. Charts de Helm

Se han creado dos charts, uno para el backend y otro para el frontend. Estos definen:

- **Deployments**: Configuración del despliegue de cada microservicio.
- **Servicios**: Expone cada componente para la comunicación entre ellos.

![Helm Charts Backend y Frontend](https://github.com/user-attachments/assets/c613b3a9-85f9-4b79-b636-dcb15c477ca2)                ![image](https://github.com/user-attachments/assets/11ed69ae-7583-44aa-b527-55a22e231fd9)


---

### 4. Infraestructura (IaC)

El proyecto incluye la definición de 16 recursos principales:

- **2 vNets**: Cada una con su subnet correspondiente.
- **2 Peerings**: Para comunicar las vNets.
- **2 Interfaces de red**: Asociadas a las máquinas virtuales.
- **1 Clúster Kubernetes**: Para desplegar el backend y frontend.
- **1 Registro de contenedores**: Almacena las imágenes Docker.
- **2 Contenedores**: Backend y frontend.
- **1 Security Group**: Control de acceso.
- **2 Máquinas virtuales**: Una para la BD y otra para los respaldos.

![Recursos IaC](https://github.com/user-attachments/assets/7aa3855c-5ccf-4637-a727-8a373f8d7710)

---

## Repositorios secundarios

### Frontend

Estructura básica de una aplicación web con un `Dockerfile` para contenerización. Incluye workflows CI/CD que utilizan los workflows reutilizables del repositorio principal.

![Estructura Frontend](https://github.com/user-attachments/assets/9e54e489-0798-4a81-bfbd-3c8853fbd421)

---

### Backend

Código backend, también containerizado, con workflows CI/CD basados en los reutilizables del repositorio principal.

![Estructura Backend](https://github.com/user-attachments/assets/4f483991-ef02-4fec-99ee-f215ae0d1596)

---

## Flujo

1. **Inicio de infraestructura**: Se realiza un merge a `main` en el repositorio principal, lo que activa los workflows de `plan` y `apply` para levantar la infraestructura.
2. **Configuración de runner**: Se conecta a la máquina virtual de respaldos vía SSH y configura un runner desde `Settings -> Actions -> Runners`.
3. **Ejecución de playbooks**: Se ejecutan los workflows `ansible` y `postgres` para preparar la BD.
4. **Despliegue del frontend y backend**:
   - CI: `SubirDockerfile.yaml` y `SubirChart.yaml` para subir los Dockerfiles y charts a Azure y Harbor.
   - CD: `Principal.yaml` para desplegar las imágenes en el clúster.

---

## Fallos y mejoras pendientes

### 1. Dockerfiles

No se logró que las imágenes Docker se construyeran correctamente, resultando en errores de tipo `ErrImagePull`. Aunque las imágenes se suben correctamente a Azure:

```bash
az acr repository list --name containerregistryvsanchez --output table
```

### 2. Disaster Recovery

El flujo de recuperación (`recuperacion.yaml`) está iniciado, pero no completado. La idea principal es implementar un mecanismo que:

1. Realice verificaciones periódicas de la integridad de la base de datos.
2. En caso de detectar problemas (base de datos dañada o ausente), restaure la base de datos a partir del último backup disponible.
3. Continúe generando backups regularmente si la base de datos está íntegra.

Actualmente, el flujo únicamente realiza backups y no restaura automáticamente.

---

### 3. ConfigMaps y secretos

Actualmente, información sensible como las contraseñas de la base de datos, las claves SSH y las credenciales de las máquinas virtuales se encuentran en texto plano. La solución planteada consiste en:

1. Utilizar **ConfigMaps** para almacenar configuraciones no sensibles.
2. Utilizar **Secretos** de Kubernetes para manejar información sensible de manera segura.
3. Actualizar los charts de Helm para que consuman estas configuraciones y secretos en lugar de incluir valores sensibles directamente.

---

## Planes a futuro

1. **Solución de errores en los Dockerfiles**: Asegurar que las imágenes se construyan correctamente y se puedan desplegar sin errores de tipo `ErrImagePull`.
2. **Implementación completa de Disaster Recovery**: Finalizar el flujo de recuperación automática para garantizar la disponibilidad continua de la base de datos.
3. **Mejoras de seguridad**: Implementar ConfigMaps y Secretos en toda la infraestructura.
4. **Optimización de CI/CD**: Simplificar y automatizar el flujo de despliegue, eliminando la necesidad de inputs manuales.


---

## Conclusión

Este proyecto ha sido un auténtico reto, y aunque no he conseguido que todo funcione como esperaba, he aprendido muchísimo durante el proceso. Los malditos Dockerfiles me han traído por la calle de la amargura con errores de `ErrImagePull` que no logré resolver a tiempo. Además, tuve que dejar a medias el flujo de recuperación de desastres porque el tiempo no daba para más. 

A pesar de todo, me ha gustado mucho trabajar en este proyecto. Ver cómo se iban construyendo las piezas poco a poco, desde la infraestructura hasta los workflows de CI/CD, ha sido súper satisfactorio. Aunque no he llegado al objetivo final, siento que he puesto una buena base que podría convertirse en algo funcional y escalable con un poco más de tiempo y paciencia.

Tengo claro que en el futuro quiero volver a este proyecto, solucionar los problemas pendientes y llevarlo al siguiente nivel. ¡Esto no termina aquí!

