# Jenkins Readme

## Índice

- :ballot_box_with_check: [Requisitos previos](#requisitos-previos)
  - :detective:[Credenciales](#credenciales)
  - :package:[Plugins](#plugins)
- :dart: [Requisitos del despliegue](#requisitos-del-despliegue)
  - :woman_mechanic:[Jobs](#jobs)
  - :diving_mask:[Pipelines](#pipelines)
  - :cloud:[Node Clouds](#node-clouds)
- :paw_prints: [Descripcion de los pasos](#descripcion-de-los-pasos)
- :bucket: [Rellenando el bucket](#rellenando-el-bucket)

## Requisitos previos

- ### Credenciales

Uno de los requisitos tiene que ver con las credenciales:

> Quieren que las credenciales para desplegar nunca estén guardadas en el código

Para ello las claves se configuran en Jenkins como:
 - credenciales: para acceder a repositorios de github desde Jenkins 
 - secretos: se cargan en el pipeline como variables de entorno que se añadirán en los agentes paraestar disponibles en tiempo de ejecución. Por ejemplo las credenciales de AWS

Para configurar las crendenciales de Github:

  - Accede a `Manage jenkins > manage credentials > Stores scoped to Jenkins > System > Global credentials (unrestricted) > Add credentials`
  - Selecciona en el select `kind` el valor `ssh username with private key`
  - Configura el campo `Id` con "ssh-github-key" por ejemplo. 
  - El usuario es "jenkins".
  - Click en `Enter directly the private key` Ahi se debe copiar la parte privada de la clave que se utilice para acceder por ssh a github. Normalmente podrás ver esa clave ejecutando: `cat ~/.ssh/id_rsa` Copia toda la salida del comando en el campo que ha aparecido en Jenkins. Pincha en `Create`


Para configurar las credenciales de AWS:
  - Accede a `Dashboard > Manage Jenkins > Credentials > System > Global credentials (unrestricted)' 
  - En la opción `Kind` seleccina Text secret 
  - En el campo **secret** introduce **el valor de la credencial** correspondiente
  - En el campo **ID** introduce en mayúsculas **la clave de la credencial** correspondiente

Este paso se debe realizarlo para *AWS_SECRET_ACCESS_KEY* y para *AWS_ACCESS_KEY_ID*

![Captura desde 2022-11-03 09-25-11](https://user-images.githubusercontent.com/2046110/200043412-b5721e50-55fe-4f18-947d-39383709694c.png)

- ### Plugins

La instalación de Jenkins ha sido realizada con los plugins recomendados y sobre ellos ha sido necesario instalar los siguientes:
- Docker
- Job DSL


## Requisitos del despliegue:

Los requisitos del despliegue son los siguientes:

>  - Quieren una unidad almacenamiento que se llamará acme-storage, será un bucket S3 de AWS

Esta parte es la relacionada con terraform y es transversal a todas las partes de la práctica.

>  - Quieren que el flujo de despliegue sea "Continuous Delivery" en la rama main, es decir, un administrador validará el comando de puesta en producción de la infraestructura

Para esta parte se ha utilizado las directivas `input` y `when{ branch 'main' }` en el paso del despliegue `(main) terraform apply`:

![image](https://user-images.githubusercontent.com/2046110/200043705-482f763e-4e36-4a53-bc7a-a0d865529583.png)


>  - Sin embargo, en otras ramas distintas de main, el despliegue será "Continuous Deployment" y no habrá aprobación manual, será totalmente automático

Para ello he replicado el paso anterior en `terraform apply` pero sin incluir la directiva `input` y con la directiva `when{ not {branch 'main'}}` para cubrir el caso de que se creen ramas adicionales.

>  - Quieren que las credenciales para desplegar nunca estén guardadas en el código

Esto está tratado en la sección [Credenciales](#credenciales)


> - Además ACME también quiere revisar cada 10 minutos que el contenido que hay en la unidad de almacenamiento no supera los 20MiB. Si esto pasa, se vaciará de manera automatizada

Se controlará a través de otro pipeline aparte.

- ### Jobs

El job para generar el pipeline del **despliegue del bucket** en S3 está en [este archivo](https://github.com/roberto-asir/practica-cicd/blob/main/jenkins/Job_DSL_deploy)

El job para generar el pipeline del **control del espacio usado** en el bucket está en [este archivo](https://github.com/roberto-asir/practica-cicd/blob/main/jenkins/Job_DSL_cron)

- ### Pipelines

El pipeline que genera **despliegue del bucket** en S3 está en [este archivo](https://github.com/roberto-asir/practica-cicd/blob/main/jenkins/Jenkinsfile)

El pipeline que genera el **control del espacio usado** en el bucket está en [este archivo](https://github.com/roberto-asir/practica-cicd/blob/main/jenkins/cronjob.Jenkinsfile)

- ### Node Clouds

Para poder utilizar los agentes necesarios para los pipelines es necesario crear y configurar un node cloud.

En este caso se usa Docker para correr los agentes y voy a utilizar dos agentes de los que hay que crear sus plantillas.

Un agente es para utilizar terraform y otro para utilizar aws-cli

![image](https://user-images.githubusercontent.com/2046110/200049263-04e2fdb4-56c0-40eb-beb0-660262a410fc.png)

## Descripcion de los pasos

Los pasos del pipeline son:
1. terraform init
2. terraform validate
3. terraform plan
4. Chek bucket exists before terraform apply
5. (main) terraform apply
6. terraform apply
7. Chek deploy

- Los pasos que ejecutan terraform tienen alguna de estas dos opciones: `-no-color` y `-auto-approve`

El motivo de usar la primera es evitar outputs raros al no saber cómo interpretar correctamente los colores Jenkins.

La segunda se utiliza para que los pasos sean automáticos y no haya que interactuar con el comando de terraform correspondiente.

- El paso 4 es un paso para verificar si existe ya el bucket que se crea en el despliegue.

Este paso ha sido necesario ya que no es posible saberlo desde terraform al iniciar el proyecto en el pipeline (se me ocurre ahora que igual se puede utilizar algún repositorio externo para guardar el estado del proyecto y así consultarlo desde cualquier intento de despliegue, tengo que mirarlo)

Para poder realizar este paso ejecuto un agente adicional: https://hub.docker.com/r/robertoasir/jenkins-terrafor-agent
El dockerfile está en el repositorio en la carpeta `jenkins/agents`

Para ello utilizo la directiva `agent{ label('awscli')}`

Es necesario por tanto añadir un nuevo `Docker Agent templates` además del añadido para utilizar terraform.
![Captura desde 2022-11-04 19-19-57](https://user-images.githubusercontent.com/2046110/200047898-8c9784f4-6b91-4e1f-8d73-f740f1378fe5.png)

## Rellenando el bucket

Para que el cronjob que vigila el espacio del disco cada 10 minutos pueda detectar que el bucket está utilizando más espacio del permitido he generado este script: [fill_up_bucket.sh](https://github.com/roberto-asir/practica-cicd/blob/main/jenkins/fill_up_bucket.sh)

