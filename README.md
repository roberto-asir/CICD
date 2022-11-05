# Practica final: Ciclo de desarrollo CI-CD

## Índice:
- :dart: [Objetivos](#objetivos)
- :mag_right:[Detalles](#detalles)
  - [Makefile](#makefile)
  - [Jenkins](#jenkins)
  - [Github Actions](#github-actions)
- :telescope: Enlaces a READMEs de cada sección:
  - [Makefile](./makefile_dir/makefile-README.md)
  - [Jenkins](./jenkins/jenkins.README.md)
  - [Github Actions](./.github/workflows/github.README.md)
  
  
## Objetivos:

La práctica está diseñada para poner a prueba los conocimientos adquiridos en el módulo sobre CI/CD del bootcamp DevOps de KeepCoding.

Es una práctica abierta con unos objetivos base sobre los que he realizado mi propuesta.

Desde la empresa ACME se nos facilitan los detalles del trabajo.

Los requerimentos que nos ha dado ACME son los siguientes:

    - Quieren una unidad almacenamiento que se llamará acme-storage, será un bucket S3 de AWS
    - Quieren que el flujo de despliegue sea "Continuous Delivery" en la rama main, es decir, un administrador validará el comando de puesta en producción de la infraestructura
    - Sin embargo, en otras ramas distintas de main, el despliegue será "Continuous Deployment" y no habrá aprobación manual, será totalmente automático
    - Los desarrolladores de ACME han de poder hacer el despliegue también desde sus máquinas
    - Quieren que las credenciales para desplegar nunca estén guardadas en el código
    - Además ACME también quiere revisar cada 10 minutos que el contenido que hay en la unidad de almacenamiento no supera los 20MiB. Si esto pasa, se vaciará de manera automatizada
    - ACME lleva usando Jenkins mucho tiempo pero está actualmente abriéndose a probar nuevas teconologías con menor coste de gestión como Github Actions. Es por esto que también se requiere un pipeline de Github actions para el despliegue de la unidad de almacenamiento, de modo que ACME pueda comparar ambas tecnologías


## Detalles:

En esta sección del README voy a explicar qué decisiones he tomado y que me ha motivado a ello.

- ### Makefile

En la parte correspondiente al despliegue en local más allá del despliegue desde terraform he realizado una doble comprobación posterior al despliegue.

La primera de ellas es en el estado del propio proyecto de terraform:
`terraform state show aws_s3_bucket.acme-storage | grep acme-storage-robertoasir`

La segunda comprobación es que el bucket realmente exista en AWS. 
Para ello podía haber utilizado aws-cli pero por experimentar un poco con python y el trabajo contra AWS decidí hacerlo a través de un script en python utilizando la librería `boto3`

El script es muy simple pero obligaba a asegurar que la librería esté instalada:
```
python_environment:
	pip3 install boto3

python_check_bucket_exists:
	python3 makefile_dir/check_remote_bucket.py
```

- ### Jenkins

En esta sección mientras realizaba el pipeline había una cosa que me volvía un poco loco y que en el makefile no pasa: 
  ¡¡Si el bucket existe al hacer `terraform apply`se produce un error y se para el pipeline!! :scream_cat:
  
![Captura desde 2022-11-04 18-00-40](https://user-images.githubusercontent.com/2046110/200033344-9354d266-bd57-4255-ae86-056a3b2c5b5b.png)

A priori podría parecer correcto pero que exista el bucket entiendo que es un problema diferente de un error en el pipeline. 
Según lo veo no debería ser un error del pipeline. 
Por este motivo he investigado cómo poder hacer que no genere un error en el pipeline y que permita seguir haciendo el resto de pasos y comprobaciones.
Además me parece un ejercicio interesante y útil para muchos otros casos.

Así he configurado una verificación previa para saber si el bucket está creado o no.

Esto me ha permitdo no realizar el paso en el que se hace el despliegue con `terraform apply` de manera que no de error.
También me ha permitido `marcarlo` para que se vea claramente y puedan consultarse los logs del paso:

![Captura desde 2022-11-04 15-40-15](https://user-images.githubusercontent.com/2046110/200034328-139b963b-b292-4a85-8fd1-fdf48dfabd33.png)

También debo destacar en este punto que la comprobación se realiza con `aws cli` y para ello he realizado un agente adicional del que se facilita el dockerfile y cuya imagen está disponible en Docker Hub

- ### Github Actions

En este caso decisiones de diseño que no sean las propias del despliegue quizá sea que he añadido un último paso que borra el bucket. 

El motivo es automatizar el borrado ya que no es necesario que quede desplegado.
También tengo en cuenta que en los logs de los actions de github queda muy claro si el despliegue se realiza de manera existosa.

![Captura desde 2022-11-04 18-14-09](https://user-images.githubusercontent.com/2046110/200036099-4453e548-1dde-42b6-bf07-2379de9af284.png)

