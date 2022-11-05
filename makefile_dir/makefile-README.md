# Makefile README 

## Índice

- :ballot_box_with_check: [Requisitos previos](#requisitos-previos)
  - [Credenciales](#credenciales)
- :dart: [Objetivo](#objetivo)
- :paw_prints: [Descripcion de los pasos](#descripcion-de-los-pasos)
- :arrow_forward: [Ejecucion](#ejecucion)

## Requisitos previos

El sistema operativo necesario para realizar la práctica es Linunx o Mac OS X.

> :information_source: No se ha chequeado si es posible realizar esta práctica en un sistema Windows. En prinicipio no es posible su ejecución en Windows, salvo que no se use software de terceros como Cygwin o, en sus últimas versiones, en la terminal de Linux integrada en el SO. En cualqueir caso como indico anteriormente no se ha comprobado.


Es necesario disponer de un entorno con las siguientes herramientas instaladas y operativas:
- make
- terraform

Por motivos de aprendizaje en esta parte de la práctica he decidido trastear un poco con la librería boto3 de python que sirve para trabajar con AWS y sus recursos.

Por este motivo además de los requisitios previos es necesario tener en el sistema:
- python3
- pip3

Este paso lo que hace es verificar que efectivamente el bucket se ha creado correctamente en la nube de AWS.

En caso de que esto no sea posible para realizar en el equipo local se puede modificar el makefile como se indica en la sección [pasos](#pasos)

- ### Credenciales
  Por último, para que terraform sea capaz de crear el bucket en AWS, es necesario tener configuradas las credenciales de AWS correctamente.

  Para obtener las credenciales sigue esta guía de la documentación oficial:
https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html

  Una vez descargado para que terraform sea capaz de leerlas de manera automática debes de mover el fichero y dejarlo con el nombre correcto según la versión de tu sistema operativo:
  https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html#specifying-your-aws-credentials-store


## Objetivo

El objetivo de este makefile es realizar un despliege de terraform que crea un bucket de almacenamiento en la nube de AWS y comprobar que se ha desplegado correctamente y que efectivamente se ha creado el recurso en el servicio en la nube.

## Descripcion de los pasos

Los pasos realizados en el makefile son:
- **terraform_init**

Realiza un `terraform init` para actualizar la configuración relacionada con los proveedores

- **terraform_apply**

Ejecuta `terraform apply` 
Se ejecuta de modo no interactivo ya que esto se ejecuta de modo local por los desarrolladores de ACME y por tanto no se aplica a un entorno de producción.

- **terraform_show**

Comprobación de que el estado de terraform tiene creado el recurso: 

`terraform state show aws_s3_bucket.acme-storage | grep acme-storage-robertoasir`

- **python_environment**

Instalación de dependencias en Python para el siguiente paso:
`pip3 install boto3`

- **python_check_bucket_exists** 

Ejecución de un script en python que utiliza la librería boto3 para verificar que efectivamente se ha creado el bucket en AWS.
Este paso y el anterior los he realizado por trastear un poco con AWS desde python. 

`python3 makefile_dir/check_remote_bucket.py`

Para que el script funcione correctamente en el proceso el script devuelve códigos de systema. `0` si el bucket existe y `1` si no existe:
```
import boto3
import sys

# Let's use Amazon S3
s3 = boto3.resource('s3')

# Print out bucket names
for bucket in s3.buckets.all():
    if bucket.name == "acme-storage-robertoasir":
        print("\nSUCCESS: Check remote bucket ok\n")
        sys.exit(0)

print("\nERROR: Remote bucket is not accesible\n")
sys.exit(1)
```


Esto mismo se puede realizar con un comando de la consola de aws que se encuentra comentado en el makefile en el paso `check_remote_resource`
```bash
aws s3api get-bucket-tagging --bucket acme-storage-robertoasir --region eu-west-1 --output json | grep "My CICD bucket"
```

> Para realizar el comando alternativo es necesario tener el comando `aws` instalado en el sistema y con las [credenciales](#credenciales) configuradas

- **final_output**

:checkered_flag::checkered_flag: Simplemente un echo indicando el éxito final: `echo "SUCCESS"` :checkered_flag::checkered_flag:


## Ejecucion

Para ejecutarlo es necesario realizar los siguientes pasos desde una termianal:

- Descargarse el repo:

	`git clone git@github.com:KeepCodingCloudDevops6/cicd-roberto.git`

- Situarse en el directorio raíz del repo:

	`cd cicd-roberto`

- Ejecutar el siguiente comando:

	`make -f makefile_dir/makefile`
